require_relative '../providers/if_statements_provider'
require_relative '../providers/blocks_provider'

module Rubyzen
  module Declarations
    class MethodDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
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
