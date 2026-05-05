module Rubyzen
  module Declarations
    # Represents a +rescue+ clause within a method or block.
    #
    # @example
    #   rescue_decl = method.rescues.first
    #   rescue_decl.exception_types #=> ["ArgumentError", "TypeError"]
    #
    class RescueDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [MethodDeclaration, BlockDeclaration]
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent [MethodDeclaration, BlockDeclaration] the parent declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns the rescued exception class names.
      # Defaults to +["StandardError"]+ for bare +rescue+.
      #
      # @return [Array<String>]
      def exception_types
        extract_exception_types
      end

      private

      def extract_exception_types
        exception_array_node = node.children[0]

        return ['StandardError'] if exception_array_node.nil?

        exception_array_node.children.map do |const_node|
          extract_const_name(const_node)
        end.compact
      end

      def extract_const_name(node)
        return nil unless node&.type == :const

        node.const_name
      end
    end
  end
end
