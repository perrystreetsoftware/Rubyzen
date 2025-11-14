module Rubyzen
  module Collections
    class RescuesCollection < BaseCollection
      def with_exception_type(exception_class)
        filter do |rescue_declaration|
          rescue_declaration.exception_types.include?(exception_class)
        end
      end
    end
  end
end
