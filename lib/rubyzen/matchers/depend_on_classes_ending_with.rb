require_relative 'matcher_helpers'

RSpec::Matchers.define :depend_on_classes_ending_with do |suffix, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers
  
  match do |classes_collection|
    @custom_message = custom_message
    @suffix = suffix

    all_constants = classes_collection.flat_map { |c| c.constants_referenced || [] }
    @offenders = all_constants.select { |const| const.end_with?(suffix) }
    !@offenders.empty?
  end

  failure_message do |classes_collection|
    message_for_failure("Expected some classes to depend on classes ending with '#{@suffix}', but none did.")
  end

  failure_message_when_negated do |classes_collection|
    message_for_failure("Expected no classes to depend on classes ending with '#{@suffix}', but found: #{@offenders.join(', ')}")
  end
end
