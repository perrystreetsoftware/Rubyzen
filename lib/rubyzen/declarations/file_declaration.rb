require_relative 'class_declaration'
require_relative '../providers/lines_of_code_provider'
require_relative '../providers/constants_provider'

module Rubyzen
  module Declarations
    class FileDeclaration
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::ConstantsProvider

      attr_reader :path, :ast

      def initialize(path, ast)
        @path = path
        @ast = ast
      end

      def name
        File.basename(path)
      end

      def classes
        @ast.each_node(:class).map do |class_node|
          ClassDeclaration.new(class_node, self)
        end
      end

      def top_level_module_name
        # If the entire file is a module, return its name
        if ast.type == :module
          return ast.identifier&.const_name
        end

        # Otherwise, find the first top-level module and return its name
        module_node = ast.children.find do |child|
          child.is_a?(RuboCop::AST::Node) && child.type == :module
        end

        module_node&.identifier&.const_name
      end

      def modules
        ast.each_node(:module).map do |module_node|
          Rubyzen::Declarations::ModuleDeclaration.new(module_node, self)
        end
      end
    end
  end
end
