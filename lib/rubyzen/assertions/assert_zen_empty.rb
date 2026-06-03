module Rubyzen
  module Assertions
    # Asserts that a Rubyzen collection is empty (the Minitest counterpart of
    # the +zen_empty+ matcher).
    #
    # Used in architectural lint rules to verify that no items match a forbidden
    # pattern (e.g., no controllers call +.where+ directly).
    #
    # @param collection [Enumerable] a Rubyzen collection of declarations
    # @param message [String, nil] optional custom failure message
    # @param allowlist [Array<String>, nil] items to permanently ignore
    # @param baseline [Array<String>, nil] known violations for gradual adoption
    # @return [true] when the assertion passes
    # @raise [Minitest::Assertion] when there are live violations or stale entries
    #
    # @example Ensure no controllers use .where
    #   assert_zen_empty(controllers.all_methods.call_sites.with_name('where'))
    #
    # @example With a baseline for gradual adoption
    #   assert_zen_empty(violations, baseline: ['LegacyController'])
    def assert_zen_empty(collection, message: nil, allowlist: nil, baseline: nil)
      @failure_message = nil
      @custom_message = message
      @classified_items = classify_items(collection, allowlist: allowlist, baseline: baseline)

      violations = @classified_items[:violations]
      stale_baseline = @classified_items[:stale_baseline]
      stale_allowlist = @classified_items[:stale_allowlist]

      stale_groups = []
      stale_groups << 'baseline entries' if stale_baseline.any?
      stale_groups << 'allowlist entries' if stale_allowlist.any?

      reason =
        if violations.any? && stale_groups.any?
          "Expected to be empty, but found live violations and stale #{stale_groups.join(' and ')}."
        elsif violations.any?
          if allowlist || baseline
            'Expected to be empty, but found live violations.'
          else
            'Expected to be empty, but had elements.'
          end
        elsif stale_groups.any?
          "Expected to be empty, but found stale #{stale_groups.join(' and ')}."
        end

      passed = violations.empty? && stale_baseline.empty? && stale_allowlist.empty?
      assert(passed, message_for_failure(reason || 'Expected to be empty, but had elements.'))
    end
  end
end
