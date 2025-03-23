require_relative 'class_declaration'

module Rubyzen
  module Declarations
    class ModuleDeclaration
      attr_reader :node, :file_declaration

      def initialize(node, file_declaration)
        @node = node
        @file_declaration = file_declaration
      end

      def name
        node.identifier&.const_name
      end

      def file_path
        file_declaration.path
      end

      def modules
        node.each_node(:module).map { |mod_node| ModuleDeclaration.new(mod_node, file_declaration) }
      end

      def classes
        node.each_node(:class).map { |class_node| ClassDeclaration.new(class_node, file_declaration) }
      end
    end
  end
end
