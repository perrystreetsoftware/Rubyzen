# @!parse
#   module Rubyzen
#     module Matchers
#       # Asserts that a block returns true for every item in a collection.
#       #
#       # @param custom_message [String, nil] optional failure message
#       # @param allowlist [Array<String>, nil] items to permanently ignore
#       # @param baseline [Array<String>, nil] known violations for gradual adoption
#       # @yield [item] block that should return true for each item
#       #
#       # @example Ensure all methods have parameters
#       #   expect(methods).to zen_true { |m| m.parameters? }
#       #
#       # @example With a custom failure message
#       #   expect(services).to zen_true("All services must inherit from BaseService") { |s| s.superclass_name == 'BaseService' }
#       def zen_true(custom_message = nil, allowlist: nil, baseline: nil, &block); end
#     end
#   end
RSpec::Matchers.define :zen_true do |custom_message=nil, allowlist: nil, baseline: nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |subject_collection|
    options = custom_message.is_a?(Hash) ? custom_message : {}
    resolved_allowlist = allowlist || options[:allowlist] || options['allowlist']
    resolved_baseline = baseline || options[:baseline] || options['baseline']
    @custom_message = options[:message] || options['message'] || (custom_message unless custom_message.is_a?(Hash))
    @offenders = []

    if block_arg != nil
      items = Array(subject_collection) # to handle one or multiple subjects

      failing_items = items.filter { |item| !block_arg.call(item) }
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
                          "Expected to return true for all elements, but found live violations and stale #{stale_exception_groups.join(' and ')}."
                        elsif @offenders.any?
                          "Expected to return true for all elements."
                        elsif stale_exception_groups.any?
                          "Expected to return true for all elements, but found stale #{stale_exception_groups.join(' and ')}."
                        end

      @offenders.empty? && stale_baseline.empty? && stale_allowlist.empty?
    else
      @failure_reason = "Expected a block, but got nil."
      false
    end
  end

  failure_message do |_|
    message_for_failure(@failure_reason || "Expected to return true for all elements.")
  end

  failure_message_when_negated do |_|
    message_for_failure("Expected to return false for at least one element, but all elements returned true.")
  end
end
