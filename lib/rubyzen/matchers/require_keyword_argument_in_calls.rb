require_relative 'matcher_helpers'

RSpec::Matchers.define :require_keyword_argument_in_calls do |receiver, method, keyword_arg, custom_message=nil|
  include Rubyzen::Matchers::MatcherHelpers
  
  match do |classes_collection|
    @custom_message = custom_message
    @receiver = receiver
    @method = method
    @keyword_arg = keyword_arg

    @offenders = []

    classes_collection.each do |class_info|
      class_info.call_sites.each do |call_site|
        if call_site[:receiver] == @receiver && call_site[:method_name] == @method
          unless call_site[:keyword_args]&.include?(@keyword_arg)
            @offenders << "#{class_info.name}: line #{call_site[:line]}"
          end
        end
      end
    end

    @offenders.empty?
  end

  failure_message do |classes_collection|
    message_for_failure("Expected some classes to include `#{@keyword_arg}:` in `#{@receiver}.#{@method}` calls, but none did.")
  end

  failure_message_when_negated do |classes_collection|
    message_for_failure("Expected no classes to include `#{@keyword_arg}:` in `#{@receiver}.#{@method}` calls, but these classes did: #{@offenders.join(', ')}")
  end
end
