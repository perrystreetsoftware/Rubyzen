module Rubyzen
  module Providers
    # Provides access to rescue clauses within a declaration.
    module RescuesProvider
      # @return [Rubyzen::Collections::RescuesCollection] collection of rescue declarations
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
