module Rubyzen
  module Declarations
    class MacroDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::SourceCodeProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def name
        node.method_name.to_s
      end

      def symbols
        node.arguments.select { |arg| arg.type == :sym }.map(&:value)
      end

      def strings
        node.arguments.select { |arg| arg.type == :str }.map(&:value)
      end

      def keyword_args
        extract_keyword_args(node)
      end

      def receiver
        node.receiver&.type == :const ? node.receiver.const_name : nil
      end

      private

      def extract_keyword_args(send_node)
        send_node.arguments.flat_map do |arg|
          if arg.hash_type?
            arg.each_pair.map do |pair|
              key_node = pair.key
              key_node.type == :sym ? key_node.value : nil
            end.compact
          else
            []
          end
        end.uniq
      end
    end
  end
end
