module Rubyzen
  module Collections
    # Collection of require/require_relative/load statements found in files.
    #
    # @example Ensuring controllers do not use require_relative
    #   expect(controller_files.requires.require_relative_calls).to zen_empty
    class RequiresCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Returns only +require+ calls.
      #
      # @return [RequiresCollection]
      def require_calls
        filter(&:require?)
      end

      # Returns only +require_relative+ calls.
      #
      # @return [RequiresCollection]
      def require_relative_calls
        filter(&:require_relative?)
      end

      # Returns only +load+ calls.
      #
      # @return [RequiresCollection]
      def load_calls
        filter(&:load?)
      end
    end
  end
end
