module Rubyzen
  module Providers
    module BlocksProvider
      def blocks
        Collections::BlocksCollection.new(
          node.each_descendant(:block).map do |block_node|
            Declarations::BlockDeclaration.new(block_node, self)
          end
        )
      end
    end
  end
end
