require_relative '../providers/line_number_provider'

module Rubyzen
  module Declarations
    class BlockDeclaration
      include Rubyzen::Providers::LineNumberProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def lines_of_code
        node.loc.expression.source.split("\n").size
      end
    end
  end
end
