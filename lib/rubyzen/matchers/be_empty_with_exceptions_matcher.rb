# @deprecated Use {be_empty} with +allowlist:+ and +baseline:+ keyword arguments instead.
#   The +be_empty+ matcher now supports all the same exception handling capabilities.
#
# Custom RSpec matcher that delegates to +be_empty+ with exception support.
# Kept for backwards compatibility only.
#
# @example Migrating to be_empty
#   # Before (deprecated):
#   expect(violations).to be_empty_with_exceptions(allowlist: ['LegacyController'])
#
#   # After (preferred):
#   expect(violations).to be_empty(allowlist: ['LegacyController'])
RSpec::Matchers.define :be_empty_with_exceptions do |custom_message=nil, allowlist: nil, baseline: nil|
  match do |subject_collection|
    warn "[DEPRECATION] `be_empty_with_exceptions` is deprecated. Use `be_empty(allowlist:, baseline:)` instead."
    @matcher = be_empty(custom_message, allowlist: allowlist, baseline: baseline)
    @matcher.matches?(subject_collection)
  end

  failure_message do |_|
    @matcher.failure_message
  end

  failure_message_when_negated do |_|
    @matcher.failure_message_when_negated
  end
end
