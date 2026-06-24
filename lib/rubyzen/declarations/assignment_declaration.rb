module Rubyzen
  module Declarations
    # Represents a local-variable assignment (an +lvasgn+ node), e.g. +x = Repos::Foo.new+.
    #
    # @example
    #   assignment = method.assignments.first
    #   assignment.name                 #=> "x"
    #   assignment.value.constructor?   #=> true
    #   assignment.value.constant_name  #=> "Repos::Foo"
    #
    # NOTE: Multiple assignment (+a, b = ...+) is only partially modelled. Each target is
    # surfaced as its own AssignmentDeclaration with a correct {#name}, but {#value} is +nil+:
    # in the AST the right-hand side lives on the enclosing +masgn+ node, not on the per-target
    # +lvasgn+, and which value each variable receives generally cannot be known statically
    # (e.g. +a, b = build_pair+). If a rule ever needs to trace destructured assignments, model
    # the shared source explicitly (a +multiple_assignment?+ predicate + +shared_source+) rather
    # than attributing the shared right-hand side to each variable's {#value}.
    #
    class AssignmentDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::SourceCodeProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [MethodDeclaration, BlockDeclaration]
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the +lvasgn+ node
      # @param parent [MethodDeclaration, BlockDeclaration] the enclosing declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns the name of the assigned local variable.
      #
      # @return [String] e.g. +"x"+
      def name
        node.children.first.to_s
      end

      # Returns the assigned value as an expression, or +nil+ when there is no value
      # node (e.g. the per-variable targets of a multiple assignment, +a, b = foo+).
      #
      # @return [ExpressionDeclaration, nil]
      def value
        value_node = node.children[1]
        return nil if value_node.nil?

        ExpressionDeclaration.new(value_node, self)
      end
    end
  end
end
