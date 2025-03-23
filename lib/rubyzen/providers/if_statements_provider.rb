require_relative '../declarations/if_statement_declaration'

module Rubyzen
  module Providers
    module IfStatementsProvider
      def if_statements
        node.each_node(:if).map { |if_node| Rubyzen::Declarations::IfStatementDeclaration.new(if_node, self) }
      end
    end
  end
end
