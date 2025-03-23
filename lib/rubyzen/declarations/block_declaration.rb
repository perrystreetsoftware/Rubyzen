module Rubyzen
  module Declarations
    class BlockDeclaration
      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def lines_of_code
        node.loc.expression.source.split("\n").size
      end

      def line
        node.loc.expression.line
      end
    end
  end
end
