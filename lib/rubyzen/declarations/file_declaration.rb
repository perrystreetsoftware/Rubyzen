require_relative 'class_declaration'

module Rubyzen
  module Declarations
    class FileDeclaration
      attr_reader :path, :ast

      def initialize(path, ast)
        @path = path
        @ast = ast
      end

      def classes
        @ast.each_node(:class).map do |class_node|
          ClassDeclaration.new(class_node, self)
        end
      end

      def top_level_module_name
        module_node = ast.children.find { |child| child.is_a?(RuboCop::AST::Node) && child.module_name? }
        return unless module_node
        module_node.const_name
      end
    end
  end
end
