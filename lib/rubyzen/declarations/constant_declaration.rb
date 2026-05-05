require_relative '../providers/file_path_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/class_name_provider'
require_relative '../providers/source_code_provider'

module Rubyzen
  module Declarations
    # Represents a constant assignment (+MAX = 100+) or reference (+MAX+).
    #
    # @example
    #   const = file.constants.filter(&:assignment?).first
    #   const.name        #=> "MAX"
    #   const.value       #=> 100
    #   const.top_level?  #=> true
    #
    class ConstantDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::SourceCodeProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [FileDeclaration, ClassDeclaration, ModuleDeclaration]
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent [FileDeclaration, ClassDeclaration, ModuleDeclaration] the parent declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns the constant name.
      #
      # @return [String]
      def name
        case node.type
        when :casgn
          node.children[1].to_s
        when :const
          node.const_name
        end
      end

      # Returns the assigned value for constant assignments.
      #
      # @return [String, Integer, Float, Boolean, nil]
      def value
        return nil unless assignment?

        value_node = node.children[2]
        return nil unless value_node

        case value_node.type
        when :str
          value_node.str_content
        when :int
          value_node.children[0]
        when :float
          value_node.children[0]
        when :true, :false
          value_node.type == :true
        else
          value_node.source
        end
      end

      # Returns whether this is a constant assignment (+:casgn+).
      #
      # @return [Boolean]
      def assignment?
        node.type == :casgn
      end

      # Returns whether this is a constant reference (+:const+).
      #
      # @return [Boolean]
      def reference?
        node.type == :const
      end

      # Returns whether this constant is defined at file scope (not inside a class or module).
      #
      # @return [Boolean]
      def top_level?
        return false unless parent.is_a?(Rubyzen::Declarations::FileDeclaration)

        current_node = node
        while current_node
          current_node = current_node.parent
          return false if current_node && (current_node.type == :class || current_node.type == :module)
        end

        true
      end

      # Returns the enclosing {ClassDeclaration}, if any.
      #
      # @return [ClassDeclaration, nil]
      def enclosing_class
        find_enclosing_ast_node(:class) do |n|
          Rubyzen::Declarations::ClassDeclaration.new(n, file_declaration)
        end
      end

      # Returns whether this constant is defined inside a class.
      #
      # @return [Boolean]
      def in_class?
        !enclosing_class.nil?
      end

      # Returns the enclosing {ModuleDeclaration}, if any.
      #
      # @return [ModuleDeclaration, nil]
      def enclosing_module
        find_enclosing_ast_node(:module) do |n|
          Rubyzen::Declarations::ModuleDeclaration.new(n, file_declaration)
        end
      end

      # Returns whether this constant is defined inside a module.
      #
      # @return [Boolean]
      def in_module?
        !enclosing_module.nil?
      end

      # Returns whether this constant is defined inside a class or module.
      #
      # @return [Boolean]
      def scoped?
        !top_level?
      end

      private

      def file_declaration
        current = parent
        while current
          return current if current.is_a?(Rubyzen::Declarations::FileDeclaration)
          return current.file_declaration if current.respond_to?(:file_declaration)
          current = current.respond_to?(:parent) ? current.parent : nil
        end
        nil
      end

      def find_enclosing_ast_node(type)
        current_node = node.parent
        while current_node
          return yield(current_node) if current_node.type == type
          current_node = current_node.respond_to?(:parent) ? current_node.parent : nil
        end
        nil
      end
    end
  end
end
