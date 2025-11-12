module Rubyzen
  module Providers
    module RescuesProvider
      def rescues
        rescue_nodes = node.each_descendant(:resbody)

        rescue_declarations = rescue_nodes.map do |rescue_node|
          Rubyzen::Declarations::RescueDeclaration.new(rescue_node, self)
        end

        Rubyzen::Collections::RescuesCollection.new(rescue_declarations)
      end
    end
  end
end
