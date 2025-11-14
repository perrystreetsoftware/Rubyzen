module Rubyzen
  module Collections
    class RaisesCollection < BaseCollection
      def with_string
        filter(&:with_string?)
      end

      def with_exception_type(exception_class)
        filter do |raise_declaration|
          raise_declaration.exception_types.include?(exception_class)
        end
      end
    end
  end
end
