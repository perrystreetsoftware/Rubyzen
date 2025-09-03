

RSpec::Matchers.define :be_empty do |custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |subject_collection|
    @custom_message = custom_message
    @offenders = []

    items = Array(subject_collection) # to handle one or multiple subjects

    items.each do |item|
      @offenders << element_name(item) if item != nil
    end

    @offenders.empty?
  end

  failure_message do |_|
    message_for_failure("Expected to be empty, but had elements.\n#{@offenders.join("\n")}")
  end

  failure_message_when_negated do |_|
    message_for_failure("Expected not to be empty, but had no elements:\n#{@offenders.join("\n")}")
  end
end
