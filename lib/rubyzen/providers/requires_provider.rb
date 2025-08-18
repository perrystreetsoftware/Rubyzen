require_relative '../declarations/require_declaration'
require_relative '../collections/requires_collection'

module Rubyzen
  module Providers
    module RequiresProvider
      def requires
        require_nodes = node.each_descendant(:send).select do |send_node|
          %w[require require_relative load].include?(send_node.method_name.to_s)
        end

        require_declarations = require_nodes.map do |require_node|
          Rubyzen::Declarations::RequireDeclaration.new(require_node, self)
        end

        Rubyzen::Collections::RequiresCollection.new(require_declarations)
      end
    end
  end
end
