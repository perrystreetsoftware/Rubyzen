# Custom RSpec matcher that asserts a Rubyzen collection is empty.
#
# Used in architectural lint rules to verify that no items match
# a forbidden pattern (e.g., no controllers call +.where+ directly).
#
# @example Ensure no controllers use .where
#   expect(controllers.that { have_call_sites_with_names('.where') }).to be_empty
#
# @example With a custom failure message
#   expect(violations).to be_empty("Controllers should not call .where directly")
RSpec::Matchers.define :be_empty do |custom_message=nil, allowlist: nil, baseline: nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |subject_collection|
    options = custom_message.is_a?(Hash) ? custom_message : {}
    resolved_allowlist = allowlist || options[:allowlist] || options['allowlist']
    resolved_baseline = baseline || options[:baseline] || options['baseline']
    @custom_message = options[:message] || options['message'] || (custom_message unless custom_message.is_a?(Hash))

    @classified_items = classify_items(
      subject_collection,
      allowlist: resolved_allowlist,
      baseline: resolved_baseline
    )
    @offenders = @classified_items[:violations]
    stale_exception_groups = []
    stale_exception_groups << 'baseline entries' if @classified_items[:stale_baseline].any?
    stale_exception_groups << 'allowlist entries' if @classified_items[:stale_allowlist].any?

    @failure_reason = if @classified_items[:violations].any? && stale_exception_groups.any?
                        "Expected to be empty, but found live violations and stale #{stale_exception_groups.join(' and ')}."
                      elsif @classified_items[:violations].any?
                        if resolved_baseline || resolved_allowlist
                          'Expected to be empty, but found live violations.'
                        else
                          'Expected to be empty, but had elements.'
                        end
                      elsif stale_exception_groups.any?
                        "Expected to be empty, but found stale #{stale_exception_groups.join(' and ')}."
                      end

    @classified_items[:violations].empty? &&
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
