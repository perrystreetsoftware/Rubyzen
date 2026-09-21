# @!parse
#   module Rubyzen
#     # Custom RSpec matchers for asserting on Rubyzen collections.
#     module Matchers
#       # Asserts that a Rubyzen collection is empty.
#       #
#       # Used in architectural lint rules to verify that no items match
#       # a forbidden pattern (e.g., no controllers call +.where+ directly).
#       #
#       # @param custom_message [String, nil] optional failure message
#       # @param allowlist [Array<String>, nil] items to permanently ignore
#       # @param baseline [Array<String>, nil] known violations for gradual adoption
#       # @param one_per_file [Boolean] if true, displays only the first violation per file (default: false)
#       #
#       # @example Ensure no controllers use .where
#       #   expect(controllers.all_methods.call_sites.with_name('where')).to zen_empty
#       #
#       # @example With baseline for gradual adoption
#       #   expect(violations).to zen_empty(baseline: ['LegacyController'])
#       #
#       # @example Compact output to one per file
#       #   expect(violations).to zen_empty(one_per_file: true)
#       def zen_empty(custom_message = nil, allowlist: nil, baseline: nil, one_per_file: false); end
#     end
#   end
RSpec::Matchers.define :zen_empty do |custom_message=nil, allowlist: nil, baseline: nil, one_per_file: false|
  include Rubyzen::ExpectationHelpers

  match do |subject_collection|
    options = custom_message.is_a?(Hash) ? custom_message : {}
    resolved_allowlist = allowlist || options[:allowlist] || options['allowlist']
    resolved_baseline = baseline || options[:baseline] || options['baseline']
    resolved_one_per_file = one_per_file || options[:one_per_file] || options['one_per_file'] || false
    @custom_message = options[:message] || options['message'] || (custom_message unless custom_message.is_a?(Hash))

    @classified_items = classify_items(
      subject_collection,
      allowlist: resolved_allowlist,
      baseline: resolved_baseline,
      one_per_file: resolved_one_per_file
    )
    @offenders = @classified_items[:violations_raw]
    stale_exception_groups = []
    stale_exception_groups << 'baseline entries' if @classified_items[:stale_baseline].any?
    stale_exception_groups << 'allowlist entries' if @classified_items[:stale_allowlist].any?

    @failure_reason = if @classified_items[:violations_raw].any? && stale_exception_groups.any?
                        "Expected to be empty, but found live violations and stale #{stale_exception_groups.join(' and ')}."
                      elsif @classified_items[:violations_raw].any?
                        if resolved_baseline || resolved_allowlist
                          'Expected to be empty, but found live violations.'
                        else
                          'Expected to be empty, but had elements.'
                        end
                      elsif stale_exception_groups.any?
                        "Expected to be empty, but found stale #{stale_exception_groups.join(' and ')}."
                      end

    @classified_items[:violations_raw].empty? &&
      @classified_items[:stale_baseline].empty? &&
      @classified_items[:stale_allowlist].empty?
  end

  failure_message do |_|
    message_for_failure(@failure_reason || 'Expected to be empty, but had elements.')
  end

  failure_message_when_negated do |_|
    message_for_failure('Expected not to be empty, but had no elements.')
  end
end
