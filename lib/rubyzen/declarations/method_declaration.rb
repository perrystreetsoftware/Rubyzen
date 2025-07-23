require_relative '../providers/if_statements_provider'
require_relative '../providers/blocks_provider'
require_relative '../providers/line_number_provider'

module Rubyzen
  module Declarations
    class MethodDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider

      attr_reader :node, :parent_class
      alias :parent :parent_class

      def initialize(node, parent_class)
        @node = node
        @parent_class = parent_class
      end

      def name
        node.method_name.to_s
      end

      def lines_of_code
        node.loc.expression.source.split("\n").size
      end
    end
  end
end
