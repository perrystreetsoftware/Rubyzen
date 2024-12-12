module Rubyzen
  module Matchers
    module MatcherHelpers
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
