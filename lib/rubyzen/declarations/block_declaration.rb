require_relative '../providers/line_number_provider'
require_relative '../providers/lines_of_code_provider'

module Rubyzen
  module Declarations
    class BlockDeclaration
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::LinesOfCodeProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end
    end
  end
end
