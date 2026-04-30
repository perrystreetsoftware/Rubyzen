RSpec::Matchers.define :be_empty_with_exceptions do |custom_message=nil, allowlist: nil, baseline: nil|
	match do |subject_collection|
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
