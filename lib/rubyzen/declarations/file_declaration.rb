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
        # If the top-level AST node itself is a module, get its name
        if ast.type == :module
          return ast.children[0].const_name if ast.children[0]&.respond_to?(:const_name)
        end

        # Otherwise, look for module nodes among the children
        module_node = ast.children.find { |child| child.is_a?(RuboCop::AST::Node) && child.type == :module }
        return unless module_node
        module_node.const_name
      end

      def modules
        ast.each_node(:module).map do |module_node|
          Rubyzen::Declarations::ModuleDeclaration.new(module_node, self)
        end
      end
    end
  end
end
