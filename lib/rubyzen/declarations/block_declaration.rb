require_relative '../providers/file_path_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/class_name_provider'
require_relative '../providers/lines_of_code_provider'

module Rubyzen
  module Declarations
    class BlockDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LinesOfCodeProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def name
        parent.name
      end
    end
  end
end
