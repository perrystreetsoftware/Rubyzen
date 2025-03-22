require_relative 'matcher_helpers'

RSpec::Matchers.define :depend_on_classes_ending_with do |suffix, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |classes_collection|
    @custom_message = custom_message
    @suffix = suffix

    @offenders = classes_collection.select do |class_decl|
      class_decl.constants_referenced.any? { |const| const.end_with?(suffix) }
    end.map(&:name)

    !@offenders.empty?
  end

  failure_message do |_classes_collection|
    message_for_failure(
      "Expected some classes to depend on classes ending with '#{@suffix}', but none did."
    )
  end

  failure_message_when_negated do |_classes_collection|
    message_for_failure(
      "Expected no classes to depend on classes ending with '#{@suffix}', but found: #{@offenders.join(', ')}"
    )
  end
end
