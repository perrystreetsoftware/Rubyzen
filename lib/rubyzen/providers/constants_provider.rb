module Rubyzen
  module Providers
    module ConstantsProvider
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
