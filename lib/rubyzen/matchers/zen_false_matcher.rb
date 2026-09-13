# @!parse
#   module Rubyzen
#     module Matchers
#       # Asserts that a block returns false for every item in a collection.
#       #
#       # Supports +allowlist:+ and +baseline:+ for gradual adoption, matching items
#       # where the block returns true against exception lists.
#       #
#       # @param custom_message [String, nil] optional failure message
#       # @param allowlist [Array<String>, nil] items to permanently ignore
#       # @param baseline [Array<String>, nil] known violations for gradual adoption
#       # @param one_per_file [Boolean] if true, displays only the first violation per file (default: false)
#       # @yield [item] block that should return false for each item
#       #
#       # @example Ensure no methods have more than 5 parameters
#       #   expect(methods).to zen_false { |m| m.parameters.size > 5 }
#       #
#       # @example With a baseline for gradual adoption
#       #   expect(classes).to zen_false(baseline: ['LegacyModel']) { |k| k.lines_of_code > 200 }
#       #
#       # @example Compact output to one per file
#       #   expect(items).to zen_false(one_per_file: true) { |x| x.bad_condition? }
#       def zen_false(custom_message = nil, allowlist: nil, baseline: nil, one_per_file: false, &block); end
#     end
#   end
RSpec::Matchers.define :zen_false do |custom_message=nil, allowlist: nil, baseline: nil, one_per_file: false|
  include Rubyzen::ExpectationHelpers

  match do |subject_collection|
    options = custom_message.is_a?(Hash) ? custom_message : {}
    resolved_allowlist = allowlist || options[:allowlist] || options['allowlist']
    resolved_baseline = baseline || options[:baseline] || options['baseline']
    resolved_one_per_file = one_per_file || options[:one_per_file] || options['one_per_file'] || false
    @custom_message = options[:message] || options['message'] || (custom_message unless custom_message.is_a?(Hash))
    @offenders = []

    if block_arg != nil
      items = Array(subject_collection)

      failing_items = items.filter { |item| block_arg.call(item) }
      @classified_items = classify_items(
        failing_items,
        allowlist: resolved_allowlist,
        baseline: resolved_baseline,
        one_per_file: resolved_one_per_file
      )
      @offenders = @classified_items[:violations_raw]

      stale_exception_groups = []
      stale_baseline = @classified_items[:stale_baseline]
      stale_allowlist = @classified_items[:stale_allowlist]
      stale_exception_groups << 'baseline entries' if stale_baseline.any?
      stale_exception_groups << 'allowlist entries' if stale_allowlist.any?

      @failure_reason = if @offenders.any? && stale_exception_groups.any?
                          "Expected to return false for all elements, but found live violations and stale #{stale_exception_groups.join(' and ')}."
                        elsif @offenders.any?
                          "Expected to return false for all elements."
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
