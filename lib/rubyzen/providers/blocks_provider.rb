module Rubyzen
  # Mixins that add capabilities (call sites, blocks, attributes, etc.) to declarations.
  module Providers
    # Provides access to block expressions (do..end and brace blocks) within a declaration.
    module BlocksProvider
      # @return [Rubyzen::Collections::BlocksCollection] collection of block declarations
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
