module Rubyzen
  module Declarations
    # Represents a method parameter.
    #
    # @example
    #   param = method.parameters.first
    #   param.name           #=> :user_id
    #   param.default_value  #=> 42
    #
    class ParameterDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [MethodDeclaration]
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent [MethodDeclaration] the parent declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns the parameter name.
      #
      # @return [Symbol]
      def name
        node.name
      end

      # Returns the default value if one is defined.
      #
      # @return [Object, nil]
      def default_value
        node.children[1]&.value
      end
    end
  end
end
