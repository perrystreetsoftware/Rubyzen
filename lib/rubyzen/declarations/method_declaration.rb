module Rubyzen
  module Declarations
    class MethodDeclaration
      attr_reader :node, :parent_class

      def initialize(node, parent_class)
        @node = node
        @parent_class = parent_class
      end

      def name
        node.method_name.to_s
      end

      def lines_of_code
        node.loc.expression.source.split("\n").size
      end
    end
  end
end
