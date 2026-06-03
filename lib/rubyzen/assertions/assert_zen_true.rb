module Rubyzen
  module Assertions
    # Asserts that a block returns true for every item in a collection (the
    # Minitest counterpart of the +zen_true+ matcher).
    #
    # @param collection [Enumerable] a Rubyzen collection of declarations
    # @param message [String, nil] optional custom failure message
    # @param allowlist [Array<String>, nil] items to permanently ignore
    # @param baseline [Array<String>, nil] known violations for gradual adoption
    # @yield [item] block that should return true for each item
    # @return [true] when the assertion passes
    # @raise [ArgumentError] when no block is given
    # @raise [Minitest::Assertion] when the block returns falsey for a live item
    #
    # @example Ensure all methods have parameters
    #   assert_zen_true(methods) { |m| m.parameters? }
    #
    # @example With a custom failure message
    #   assert_zen_true(services, message: 'All services must inherit from BaseService') { |s| s.superclass_name == 'BaseService' }
    def assert_zen_true(collection, message: nil, allowlist: nil, baseline: nil, &block)
      raise ArgumentError, 'assert_zen_true requires a block' unless block

      @failure_message = nil
      @custom_message = message
      failing_items = Array(collection).filter { |item| !block.call(item) }
      @classified_items = classify_items(failing_items, allowlist: allowlist, baseline: baseline)

      violations = @classified_items[:violations]
      stale_baseline = @classified_items[:stale_baseline]
      stale_allowlist = @classified_items[:stale_allowlist]

      stale_groups = []
      stale_groups << 'baseline entries' if stale_baseline.any?
      stale_groups << 'allowlist entries' if stale_allowlist.any?

      reason =
        if violations.any? && stale_groups.any?
          "Expected to return true for all elements, but found live violations and stale #{stale_groups.join(' and ')}."
        elsif violations.any?
          'Expected to return true for all elements.'
        elsif stale_groups.any?
          "Expected to return true for all elements, but found stale #{stale_groups.join(' and ')}."
        end

      passed = violations.empty? && stale_baseline.empty? && stale_allowlist.empty?
      assert(passed, message_for_failure(reason || 'Expected to return true for all elements.'))
    end
  end
end
