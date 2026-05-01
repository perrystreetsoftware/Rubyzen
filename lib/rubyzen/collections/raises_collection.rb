module Rubyzen
  module Collections
    # Collection of raise declarations found in methods or classes.
    #
    # @example Ensuring no plain-string raises in controllers
    #   expect(controllers.raises.with_string).to be_empty
    class RaisesCollection < BaseCollection
      # Filters raises that use a plain string message (not an exception class).
      #
      # @return [RaisesCollection]
      def with_string
        filter(&:with_string?)
      end

      # Filters raises that include the given exception class.
      #
      # @param exception_class [String] the exception class name to match
      # @return [RaisesCollection]
      def with_exception_type(exception_class)
        filter do |raise_declaration|
          raise_declaration.exception_types.include?(exception_class)
        end
      end
    end
  end
end
