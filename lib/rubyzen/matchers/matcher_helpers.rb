module Rubyzen
  module Matchers
    module MatcherHelpers
      def element_name(item)
        element_name = if item.respond_to?(:name)
          item.name
        elsif item.respond_to?(:class_name)
          item.class_name
        else
          'UnknownDeclaration'
        end

        file_path = (item.respond_to?(:file_path) ? item.file_path : 'Unknown file')
        "  - `#{element_name}` in #{file_path}:#{item.line}"
      end

      def self.included(base)
        base.define_method(:message_for_failure) do |base_message|
          if @custom_message
            if @offenders.any?
              "#{@custom_message}\nViolations: #{@offenders.join(', ')}"
            else
              @custom_message
            end
          else
            base_message
          end
        end
      end
    end
  end
end
