require_relative '../declarations/block_declaration'

module Rubyzen
  module Providers
    module BlocksProvider
      def blocks
        node.each_node(:block).map do |block_node|
          Rubyzen::Declarations::BlockDeclaration.new(block_node, self)
        end
      end
    end
  end
end
