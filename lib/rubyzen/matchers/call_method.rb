require_relative 'matcher_helpers'

RSpec::Matchers.define :call_method do |method_names, on_receivers: nil, message: nil|
  include Rubyzen::Matchers::MatcherHelpers

  match do |classes_collection|
    @custom_message = message
    @method_names = Array(method_names).map { |m| m.to_s.sub(/^:/, '') }

    @on_receivers = if on_receivers
                      if on_receivers.respond_to?(:map)
                        on_receivers.map(&:name)
                      else
                        Array(on_receivers)
                      end
                    end

    @offenders = classes_collection.select do |class_decl|
      if @on_receivers
        class_decl.call_sites.any? do |call_site|
          @method_names.include?(call_site[:method_name]) &&
            @on_receivers.include?(call_site[:receiver])
        end
      else
        (class_decl.called_method_names & @method_names).any?
      end
    end.map(&:name)

    !@offenders.empty?
  end

  failure_message do |_classes_collection|
    methods_list  = @method_names.size > 1 ? @method_names.join(', ') : @method_names.first
    receiver_msg  = @on_receivers ? " on #{@on_receivers.join(', ')}" : ""
    message_for_failure(
      @custom_message || "Expected some classes to call `#{methods_list}`#{receiver_msg}, but none did."
    )
  end

  failure_message_when_negated do |_classes_collection|
    methods_list  = @method_names.size > 1 ? @method_names.join(', ') : @method_names.first
    receiver_msg  = @on_receivers ? " on #{@on_receivers.join(', ')}" : ""
    message_for_failure(
      @custom_message || "Expected no classes to call `#{methods_list}`#{receiver_msg}, but these classes did: #{@offenders.join(', ')}"
    )
  end
end
