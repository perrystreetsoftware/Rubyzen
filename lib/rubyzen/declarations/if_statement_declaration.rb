module Rubyzen
  module Declarations
    class IfStatementDeclaration
      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def line
        node.loc.expression.line
      end

      def condition_source
        node.condition&.source
      end
    end
  end
end
