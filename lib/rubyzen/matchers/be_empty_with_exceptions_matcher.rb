RSpec::Matchers.define :be_empty_with_exceptions do |custom_message=nil, allowlist: nil, baseline: nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |subject_collection|
    @custom_message = custom_message
    @classified_items = classify_items(subject_collection, allowlist: allowlist, baseline: baseline)
    @offenders = @classified_items[:violations]
    stale_exception_groups = []
    stale_exception_groups << 'baseline entries' if @classified_items[:stale_baseline].any?
    stale_exception_groups << 'allowlist entries' if @classified_items[:stale_allowlist].any?

    @failure_reason = if @classified_items[:violations].any? && stale_exception_groups.any?
                        "Expected to be empty, but found live violations and stale #{stale_exception_groups.join(' and ')}."
                      elsif @classified_items[:violations].any?
                        'Expected to be empty, but found live violations.'
                      elsif stale_exception_groups.any?
                        "Expected to be empty, but found stale #{stale_exception_groups.join(' and ')}."
                      end

    @classified_items[:violations].empty? &&
      @classified_items[:stale_baseline].empty? &&
      @classified_items[:stale_allowlist].empty?
  end

  failure_message do |_|
    message_for_failure(@failure_reason || 'Expected to be empty, but had unmatched elements.')
  end

  failure_message_when_negated do |_|
    message_for_failure('Expected not to be empty, but had no matched elements.')
  end
end
