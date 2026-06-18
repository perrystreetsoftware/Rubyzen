module Rubyzen
  module Providers
    # Provides the value-expression(s) a method or block evaluates to: the implicit
    # final expression of the body plus any explicit +return+ arguments.
    module ReturnExpressionsProvider
      # @return [Rubyzen::Collections::ExpressionsCollection]
      def return_expressions
        nodes = []
        body = node.body
        nodes << (body.begin_type? ? body.children.last : body) unless body.nil?
        node.each_descendant(:return).each do |return_node|
          nodes << return_node.children.first
        end

        Collections::ExpressionsCollection.new(
          nodes.compact.map do |expression_node|
            Declarations::ExpressionDeclaration.new(expression_node, self)
          end
        )
      end
    end
  end
end
