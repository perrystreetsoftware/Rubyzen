module Rubyzen
  module Providers
    # Provides the chain of blocks (do..end / { }) that lexically enclose a declaration,
    # innermost first.
    module EnclosingBlocksProvider
      # @return [Rubyzen::Collections::BlocksCollection]
      def enclosing_blocks
        Collections::BlocksCollection.new(
          node.each_ancestor(:block).map do |block_node|
            Declarations::BlockDeclaration.new(block_node, parent)
          end
        )
      end
    end
  end
end
