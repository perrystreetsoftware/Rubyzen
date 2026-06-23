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

      # Filters to only constant expressions, including constructors of a constant
      # (e.g. both +Repos::Foo+ and +Repos::Foo.new+).
      #
      # @return [ExpressionsCollection]
      def constants
        filter(&:constant_name)
      end
    end
  end
end
