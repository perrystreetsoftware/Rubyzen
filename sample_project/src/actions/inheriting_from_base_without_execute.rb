module Builders
  module Actions
    class InheritingFromBaseWithoutExecute < BaseWithoutExecute
      def initialize(some_arg:)
      end

      private

      def some_method
      end
    end
  end
end
