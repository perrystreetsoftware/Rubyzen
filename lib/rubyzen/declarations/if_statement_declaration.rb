module Rubyzen
  module Declarations
    class IfStatementDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::SourceCodeProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def condition_source
        node.condition&.source
      end

      def name
        parent.name
      end
    end
  end
end
