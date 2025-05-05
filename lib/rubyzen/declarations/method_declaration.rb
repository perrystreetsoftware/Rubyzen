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

      def public_method?
        node_visibility == :public
      end

      private

      def node_visibility
        # Traverse upward to the class or module body
        class_or_module = node.each_ancestor(:class, :module).first
        return :public unless class_or_module

        visibility = :public
        class_or_module.body.each_child_node do |child|
          if child.send_type? && %i[public protected private].include?(child.method_name)
            visibility = child.method_name
          elsif child.def_type? || child.defs_type?
            return visibility if child == node
          end
        end

        :public
      end
    end
  end
end
