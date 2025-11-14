module Rubyzen
  module Declarations
    class RescueDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def exception_types
        extract_exception_types
      end

      private

      def extract_exception_types
        exception_array_node = node.children[0]

        return ['StandardError'] if exception_array_node.nil?

        exception_array_node.children.map do |const_node|
          extract_const_name(const_node)
        end.compact
      end

      def extract_const_name(node)
        return nil unless node&.type == :const

        node.const_name
      end
    end
  end
end
