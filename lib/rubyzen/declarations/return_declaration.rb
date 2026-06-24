module Rubyzen
  module Declarations
    # Represents a single point at which a method or block yields a value: the
    # implicit final expression of its body, or an explicit +return+ statement.
    #
    # @example
    #   ret = method.returns.first
    #   ret.explicit?                 #=> false
    #   ret.expression.hash_literal?  #=> true
    #
    class ReturnDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::SourceCodeProvider

      # @return [RuboCop::AST::Node] the +return+ node, or the implicit final-expression node
      attr_reader :node

      # @return [MethodDeclaration, BlockDeclaration] the declaration that returns this value
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the +return+ node, or the implicit final-expression node
      # @param parent [MethodDeclaration, BlockDeclaration] the enclosing declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # @return [Boolean] true if this is an explicit +return+ statement
      def explicit?
        node.return_type?
      end

      # @return [Boolean] true if this is the implicit final expression of the body
      def implicit?
        !explicit?
      end

      # The value expression being returned.
      #
      # @return [ExpressionDeclaration, nil] +nil+ for a bare +return+ with no value
      def expression
        value_node = explicit? ? node.children.first : node
        return nil if value_node.nil?

        ExpressionDeclaration.new(value_node, self)
      end
    end
  end
end
