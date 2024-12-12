require_relative 'matcher_helpers'

RSpec::Matchers.define :have_top_level_module do |expected_module, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers
  
  match do |classes_collection|
    @custom_message = custom_message
    @expected_module = expected_module

    @offenders = classes_collection.select do |class_info|
      class_info.top_level_module != @expected_module
    end.map(&:name)

    @offenders.empty?
  end

  failure_message do |classes_collection|
    message_for_failure("Expected all classes to be defined under '#{@expected_module}' module, but these were not: #{@offenders.join(', ')}")
  end

  failure_message_when_negated do |classes_collection|
    message_for_failure("Expected some classes to be defined under '#{@expected_module}' module, but none were.")
  end
end
