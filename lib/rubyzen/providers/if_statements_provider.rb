module Rubyzen
  module Providers
    # Provides access to if/unless conditional statements within a declaration.
    module IfStatementsProvider
      # @return [Rubyzen::Collections::DeclarationCollection] collection of if statement declarations
      def if_statements
        Rubyzen::Collections::DeclarationCollection.new(node.each_node(:if).map { |if_node| Rubyzen::Declarations::IfStatementDeclaration.new(if_node, self) })
      end
    end
  end
end
