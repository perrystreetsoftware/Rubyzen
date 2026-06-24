module Rubyzen
  module Providers
    # Provides the arguments passed at a call site (or macro), as expressions.
    module ArgumentsProvider
      # @return [Rubyzen::Collections::ArgumentsCollection]
      def arguments
        Collections::ArgumentsCollection.new(
          node.arguments.map do |argument_node|
            Declarations::ExpressionDeclaration.new(argument_node, self)
          end
        )
      end
    end
  end
end
