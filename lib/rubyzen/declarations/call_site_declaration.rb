
module Rubyzen
  module Declarations
    class CallSiteDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::SourceCodeProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def name
        method_name
      end

      def receiver
        node.receiver&.type == :const ? node.receiver.const_name : nil
      end

      def method_name
         node.method_name.to_s
      end

      def keyword_args
        node.arguments.flat_map do |arg|
          next [] unless arg.hash_type?

          arg.pairs.filter_map do |pair|
            pair.key.value if pair.key.type == :sym
          end
        end.uniq
      end

      def keyword_arg_value_pairs
        result = {}
        node.arguments.each do |arg|
          next unless arg.hash_type?

          arg.pairs.each do |pair|
            next unless pair.key.type == :sym

            value_node = pair.value
            result[pair.key.value] = value_node.respond_to?(:value) ? value_node.value : nil
          end
        end
        result
      end

      def symbols
        node.arguments.select { |arg| arg.type == :sym }.map(&:value)
      end

      def strings
        node.arguments.select { |arg| arg.type == :str }.map(&:value)
      end

    end
  end
end
