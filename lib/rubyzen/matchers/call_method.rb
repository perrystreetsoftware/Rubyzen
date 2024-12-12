require_relative 'matcher_helpers'

RSpec::Matchers.define :call_method do |method_name, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers
  
  match do |classes_collection|
    @custom_message = custom_message
    @method_name = method_name
    called_methods = classes_collection.flat_map { |c| c.called_method_names }
    @offenders = called_methods.include?(@method_name) ? [@method_name] : []
    !@offenders.empty?
  end

  failure_message do |classes_collection|
    message_for_failure("Expected some classes to call `#{@method_name}`, but none did.")
  end

  failure_message_when_negated do |classes_collection|
    message_for_failure("Expected no classes to call `#{@method_name}`, but these classes did: #{@offenders.join(', ')}")
  end
end
