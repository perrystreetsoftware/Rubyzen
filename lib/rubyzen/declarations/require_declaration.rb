require_relative '../providers/file_path_provider'
require_relative '../providers/line_number_provider'

module Rubyzen
  module Declarations
    class RequireDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider

      attr_reader :node, :parent_file
      alias :parent :parent_file

      def initialize(node, parent_file)
        @node = node
        @parent_file = parent_file
      end

      def name
        node.method_name.to_s
      end

      def required_path
        first_arg = node.arguments.first
        return nil unless first_arg&.type == :str
        first_arg.value
      end

      def require?
        name == 'require'
      end

      def require_relative?
        name == 'require_relative'
      end

      def load?
        name == 'load'
      end
    end
  end
end
