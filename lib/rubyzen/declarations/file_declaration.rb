require_relative 'class_declaration'
require_relative 'rspec_declaration'

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
        if ast.type == :module
          return ast.children[0].const_name if ast.children[0]&.respond_to?(:const_name)
        end

        module_node = ast.children.find { |child| child.is_a?(RuboCop::AST::Node) && child.type == :module }
        return unless module_node
        module_node.const_name
      end

      def modules
        ast.each_node(:module).map do |module_node|
          Rubyzen::Declarations::ModuleDeclaration.new(module_node, self)
        end
      end

      def rspec_declaration
        return nil unless is_rspec_file?

        RspecDeclaration.new(ast, self)
      end

      def is_rspec_file?
        has_rspec_describes?
      end

      private

      def has_rspec_describes?
        ast.each_node(:send).any? { |node| rspec_describe_node?(node) }
      end

      def rspec_describe_node?(node)
        node.method_name == :describe && node.receiver.nil?
      end
    end
  end
end
