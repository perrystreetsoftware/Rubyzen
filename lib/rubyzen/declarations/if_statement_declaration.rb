require_relative '../providers/file_path_provider'
require_relative '../providers/class_name_provider'
require_relative '../providers/line_number_provider'

module Rubyzen
  module Declarations
    class IfStatementDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def condition_source
        node.condition&.source
      end
    end
  end
end
