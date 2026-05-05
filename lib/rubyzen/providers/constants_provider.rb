module Rubyzen
  module Providers
    # Provides access to constant references and assignments within a declaration.
    module ConstantsProvider
      # @return [Rubyzen::Collections::ConstantsCollection] collection of constant declarations
      def constants
        constant_nodes = node.each_descendant(:casgn, :const)

        Collections::ConstantsCollection.new(
          constant_nodes.map do |const_node|
            Declarations::ConstantDeclaration.new(const_node, self)
          end
        )
      end
    end
  end
end
