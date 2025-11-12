module Rubyzen
  module Declarations
    class RaiseDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::SourceCodeProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def exception_types
        extract_exception_types
      end

      def with_string?
        first_arg = node.arguments.first
        first_arg&.type == :str
      end

      def message
        extract_message
      end

      private

      def extract_exception_types
        first_arg = node.arguments.first

        return ['RuntimeError'] if first_arg.nil? || first_arg.type == :str

        if first_arg.type == :const
          [first_arg.const_name]
        elsif first_arg.type == :send && first_arg.method_name == :new
          receiver = first_arg.receiver
          receiver&.type == :const ? [receiver.const_name] : ['RuntimeError']
        else
          ['RuntimeError']
        end
      end

      def extract_message
        first_arg = node.arguments.first
        second_arg = node.arguments[1]

        if first_arg&.type == :str
          first_arg.value
        elsif second_arg&.type == :str
          second_arg.value
        elsif first_arg&.type == :send && first_arg.method_name == :new
          msg_arg = first_arg.arguments.first
          msg_arg&.type == :str ? msg_arg.value : nil
        else
          nil
        end
      end
    end
  end
end
