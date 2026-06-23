module Rubyzen
  module Collections
    # Collection of {Rubyzen::Declarations::ReturnDeclaration} — the points at which a
    # method or block yields a value.
    #
    # @example
    #   method.returns.expressions.hash_literals
    class ReturnsCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # The value expressions of every return. Bare +return+s (which have no value)
      # are omitted.
      #
      # @return [ExpressionsCollection]
      def expressions
        ExpressionsCollection.new(filter_map(&:expression))
      end
    end
  end
end
