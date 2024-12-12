require_relative 'matcher_helpers'

RSpec::Matchers.define :call_method do |method_name, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |classes_collection|
    @custom_message = custom_message
    @method_name = method_name.to_s

    @offenders = classes_collection.select do |class_info|
      class_info.called_method_names.include?(@method_name)
    end.map(&:name)

    !@offenders.empty?
  end

  failure_message do |classes_collection|
    message_for_failure("Expected some classes to call `#{@method_name}`, but none did.")
  end

  failure_message_when_negated do |classes_collection|
    message_for_failure("Expected no classes to call `#{@method_name}`, but these classes did: #{@offenders.join(', ')}")
  end
end
