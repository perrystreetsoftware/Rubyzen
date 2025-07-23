require_relative '../declarations/if_statement_declaration'
require_relative '../collections/declaration_collection'

module Rubyzen
  module Providers
    module IfStatementsProvider
      def if_statements
        Rubyzen::Collections::DeclarationCollection.new(node.each_node(:if).map { |if_node| Rubyzen::Declarations::IfStatementDeclaration.new(if_node, self) })
      end
    end
  end
end
