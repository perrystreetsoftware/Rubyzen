module Rubyzen
  module Declarations
    # Represents an arbitrary Ruby value-expression node — the value a method returns,
    # the receiver of a call, a positional argument, the value of an assignment, and so on.
    # Wraps any AST node and exposes its "kind" through predicates, so rules can ask
    # structural questions without touching the raw AST.
    #
    # @example
    #   expr = call_site.receiver_expression
    #   expr.constructor?     #=> true   (for Repos::Foo.new.bar)
    #   expr.constant_name    #=> "Repos::Foo"
    #
    class ExpressionDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::SourceCodeProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [Object] the declaration that produced this expression
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the value-expression node
      # @param parent [Object] the declaration that produced this expression
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns a short identifier: the constant, variable, or method name, falling
      # back to the node type.
      #
      # @return [String]
      def name
        constant_name || local_variable_name || (method_call? ? method_name : node.type.to_s)
      end

      # @return [Boolean] true if the expression is a bare constant, e.g. +Repos::Foo+
      def constant?
        node.const_type?
      end

      # @return [Boolean] true if the expression references a local variable
      def local_variable?
        node.lvar_type?
      end

      # @return [Boolean] true if the expression is a method call (a +send+ node)
      def method_call?
        node.send_type?
      end

      # @return [Boolean] true if the expression is a constructor call, e.g. +Repos::Foo.new+
      def constructor?
        method_call? && node.method_name == :new
      end

      # @return [Boolean] true if the expression is a braced Hash literal with at least one pair
      def hash_literal?
        node.hash_type? && node.braces? && node.pairs.any?
      end

      # @return [Boolean] true if the expression is a symbol literal
      def symbol?
        node.sym_type?
      end

      # @return [Boolean] true if the expression is a string literal
      def string?
        node.str_type?
      end

      # Returns the constant name when the expression is a constant or constructs from one.
      #
      # @return [String, nil] e.g. +"Repos::Foo"+ for both +Repos::Foo+ and +Repos::Foo.new+
      def constant_name
        return node.const_name if constant?
        return node.receiver.const_name if constructor? && node.receiver&.const_type?

        nil
      end

      # Returns the called method name when the expression is a method call.
      #
      # @return [String, nil]
      def method_name
        node.method_name.to_s if method_call?
      end

      private

      def local_variable_name
        node.children.first.to_s if local_variable?
      end
    end
  end
end
