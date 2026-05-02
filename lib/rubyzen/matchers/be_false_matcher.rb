# Custom RSpec matcher that asserts a block returns false for every item in a collection.
#
# Supports +allowlist:+ and +baseline:+ for gradual adoption, matching items
# where the block returns true against exception lists.
#
# @example Ensure no methods have more than 5 parameters
#   expect(methods).to be_false { |m| m.parameters.size > 5 }
#
# @example With a custom failure message
#   expect(controllers.all_methods.call_sites).to be_false("Controllers must not call .where directly") { |cs| cs.name == 'where' }
#
# @example With a baseline for gradual adoption
#   expect(classes).to be_false(baseline: ['LegacyModel']) { |k| k.lines_of_code > 200 }
RSpec::Matchers.define :be_false do |custom_message=nil, allowlist: nil, baseline: nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |subject_collection|
    options = custom_message.is_a?(Hash) ? custom_message : {}
    resolved_allowlist = allowlist || options[:allowlist] || options['allowlist']
    resolved_baseline = baseline || options[:baseline] || options['baseline']
    @custom_message = options[:message] || options['message'] || (custom_message unless custom_message.is_a?(Hash))
    @offenders = []

    if block_arg != nil
      items = Array(subject_collection)

      failing_items = items.filter { |item| block_arg.call(item) }
      @classified_items = classify_items(
        failing_items,
        allowlist: resolved_allowlist,
        baseline: resolved_baseline
      )
      @offenders = @classified_items[:violations]

      stale_exception_groups = []
      stale_baseline = @classified_items[:stale_baseline]
      stale_allowlist = @classified_items[:stale_allowlist]
      stale_exception_groups << 'baseline entries' if stale_baseline.any?
      stale_exception_groups << 'allowlist entries' if stale_allowlist.any?

      @failure_reason = if @offenders.any? && stale_exception_groups.any?
                          "Expected to return false for all elements, but found live violations and stale #{stale_exception_groups.join(' and ')}."
                        elsif @offenders.any?
                          "Expected to return false for all elements, but returned true for:\n#{@offenders.join("\n")}"
                        elsif stale_exception_groups.any?
                          "Expected to return false for all elements, but found stale #{stale_exception_groups.join(' and ')}."
                        end

      @offenders.empty? && stale_baseline.empty? && stale_allowlist.empty?
    else
      @failure_reason = "Expected a block, but got nil."
      false
    end
  end

  failure_message do |_|
    message_for_failure(@failure_reason || "Expected to return false for all elements.")
  end

  failure_message_when_negated do |_|
    message_for_failure("Expected to return true for at least one element, but all elements returned false.")
  end
end
