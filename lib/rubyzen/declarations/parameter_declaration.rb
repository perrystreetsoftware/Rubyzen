module Rubyzen
  module Declarations
    class ParameterDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def name
        node.name
      end

      def default_value
        node.children[1]&.value
      end
    end
  end
end