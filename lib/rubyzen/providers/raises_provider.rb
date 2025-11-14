module Rubyzen
  module Providers
    module RaisesProvider
      def raises
        raise_nodes = node.each_descendant(:send).select do |send_node|
          send_node.method_name == :raise
        end

        raise_declarations = raise_nodes.map do |raise_node|
          Rubyzen::Declarations::RaiseDeclaration.new(raise_node, self)
        end

        Rubyzen::Collections::RaisesCollection.new(raise_declarations)
      end
    end
  end
end
