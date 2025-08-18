module Rubyzen
  module Matchers
    module MatcherHelpers
      def element_name(item)
        name = item.respond_to?(:name) ? item.name : nil
        class_name = item.respond_to?(:class_name) ? item.class_name : nil
        file_path = item.respond_to?(:file_path) ? item.file_path : 'Unknown file'
        location = "#{file_path}:#{item.line}"

        case
        when name && class_name
          "  - element: #{name}\n  - class: #{class_name}\n  - file: #{location}"
        when name
          "  - element: #{name}\n  - file: #{location}"
        when class_name
          "  - class: #{class_name}\n  - file: #{location}"
        else
          "  - unknown element in #{location}"
        end
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
