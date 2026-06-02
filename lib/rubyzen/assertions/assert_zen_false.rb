module Rubyzen
  module Assertions
    # Asserts that a block returns false for every item in a collection (the
    # Minitest counterpart of the +zen_false+ matcher).
    #
    # @param collection [Enumerable] a Rubyzen collection of declarations
    # @param message [String, nil] optional custom failure message
    # @param allowlist [Array<String>, nil] items to permanently ignore
    # @param baseline [Array<String>, nil] known violations for gradual adoption
    # @yield [item] block that should return false for each item
    # @return [true] when the assertion passes
    # @raise [ArgumentError] when no block is given
    # @raise [Minitest::Assertion] when the block returns truthy for a live item
    #
    # @example Ensure no methods have more than 5 parameters
    #   assert_zen_false(methods) { |m| m.parameters.size > 5 }
    #
    # @example With a baseline for gradual adoption
    #   assert_zen_false(classes, baseline: ['LegacyModel']) { |k| k.lines_of_code > 200 }
    def assert_zen_false(collection, message: nil, allowlist: nil, baseline: nil, &block)
      raise ArgumentError, 'assert_zen_false requires a block' unless block

      @failure_message = nil
      @custom_message = message
      failing_items = Array(collection).filter { |item| block.call(item) }
      @classified_items = classify_items(failing_items, allowlist: allowlist, baseline: baseline)

      violations = @classified_items[:violations]
      stale_baseline = @classified_items[:stale_baseline]
      stale_allowlist = @classified_items[:stale_allowlist]

      stale_groups = []
      stale_groups << 'baseline entries' if stale_baseline.any?
      stale_groups << 'allowlist entries' if stale_allowlist.any?

      reason =
        if violations.any? && stale_groups.any?
          "Expected to return false for all elements, but found live violations and stale #{stale_groups.join(' and ')}."
        elsif violations.any?
          'Expected to return false for all elements.'
        elsif stale_groups.any?
          "Expected to return false for all elements, but found stale #{stale_groups.join(' and ')}."
        end

      passed = violations.empty? && stale_baseline.empty? && stale_allowlist.empty?
      assert(passed, message_for_failure(reason || 'Expected to return false for all elements.'))
    end
  end
end
