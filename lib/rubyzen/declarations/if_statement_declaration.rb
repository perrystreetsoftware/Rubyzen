module Rubyzen
  module Declarations
    # Represents an +if+ / +unless+ statement within a method or class.
    #
    # @example
    #   if_stmt = method.if_statements.first
    #   if_stmt.condition_source #=> "user.active?"
    #   if_stmt.source_code      #=> "if user.active?\n  ..."
    #
    class IfStatementDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::SourceCodeProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [MethodDeclaration, ClassDeclaration]
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent [MethodDeclaration, ClassDeclaration] the parent declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns the raw source of the condition expression.
      #
      # @return [String, nil]
      def condition_source
        node.condition&.source
      end

      # Returns the name of the parent declaration.
      #
      # @return [String]
      def name
        parent.name
      end
    end
  end
end
