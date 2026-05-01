module Rubyzen
  module Collections
    # Collection of rescue declarations found in methods or classes.
    #
    # @example Checking for StandardError rescues
    #   project.files.classes.all_methods.rescues.with_exception_type('StandardError')
    class RescuesCollection < BaseCollection
      # Filters rescues that handle the given exception class.
      #
      # @param exception_class [String] the exception class name to match
      # @return [RescuesCollection]
      def with_exception_type(exception_class)
        filter do |rescue_declaration|
          rescue_declaration.exception_types.include?(exception_class)
        end
      end
    end
  end
end
