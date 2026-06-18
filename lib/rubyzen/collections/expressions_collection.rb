module Rubyzen
  module Collections
    # Collection of {Rubyzen::Declarations::ExpressionDeclaration} — return values,
    # call arguments, and other value-expressions.
    #
    # @example
    #   method.return_expressions.hash_literals
    class ExpressionsCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Filters to only braced Hash-literal expressions.
      #
      # @return [ExpressionsCollection]
      def hash_literals
        filter(&:hash_literal?)
      end

      # Filters to only constant (or constructor-of-constant) expressions.
      #
      # @return [ExpressionsCollection]
      def constants
        filter(&:constant?)
      end
    end
  end
end
