

RSpec::Matchers.define :be_true do |custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |subject_collection|
    @custom_message = custom_message
    @offenders = []

    if block_arg != nil
      items = Array(subject_collection) # to handle one or multiple subjects

      items.each do |item|
        @offenders << element_name(item) unless block_arg.call(item)
      end

      @offenders.empty?
    else
      @failure_message = "Expected a block, but got nil."
      false
    end
  end

  failure_message do |_|
    message_for_failure("Expected to return true for all elements, but returned false for:\n#{@offenders.join("\n")}")
  end

  failure_message_when_negated do |_|
    message_for_failure("Expected to return false for at least one element, but returned true for:\n#{@offenders.join("\n")}")
  end
end
