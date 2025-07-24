require_relative '../providers/file_path_provider'
require_relative '../providers/line_number_provider'

module Rubyzen
  module Declarations
    class CallSiteDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider

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
         extract_keyword_args(node)
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
