require_relative '../providers/file_path_provider'
require_relative '../providers/class_name_provider'

module Rubyzen
  module Declarations
    class IfStatementDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def line
        node.loc.expression.line
      end

      def condition_source
        node.condition&.source
      end
    end
  end
end
