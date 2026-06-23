module Rubyzen
  module Providers
    # Provides the points at which a method or block yields a value: the implicit final
    # expression of its body, plus every explicit +return+. Each is wrapped in a
    # {Rubyzen::Declarations::ReturnDeclaration}, which knows how to extract its own value.
    module ReturnsProvider
      # @return [Rubyzen::Collections::ReturnsCollection]
      def returns
        Collections::ReturnsCollection.new(
          return_nodes.map do |return_node|
            Declarations::ReturnDeclaration.new(return_node, self)
          end
        )
      end

      # The value-expression(s) this method or block evaluates to, as a flat collection.
      # A shortcut for +returns.expressions+.
      #
      # @return [Rubyzen::Collections::ExpressionsCollection]
      def return_expressions
        returns.expressions
      end

      private

      # The return points to wrap: the implicit final expression of the body (unless it is
      # itself an explicit +return+, which is collected separately to avoid double-counting),
      # followed by every explicit +return+.
      def return_nodes
        nodes = []
        final = implicit_final_node
        nodes << final unless final.nil?
        node.each_descendant(:return) { |return_node| nodes << return_node }
        nodes
      end

      # The node a body implicitly evaluates to: the last statement of a multi-statement
      # body (+begin+) or an explicit +begin..end+ (+kwbegin+), otherwise the body itself.
      # Returns +nil+ when that node is an explicit +return+ (collected separately).
      def implicit_final_node
        body = node.body
        return nil if body.nil?

        final = body.begin_type? || body.kwbegin_type? ? body.children.last : body
        final unless final.return_type?
      end
    end
  end
end
