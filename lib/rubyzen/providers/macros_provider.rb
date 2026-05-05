module Rubyzen
  module Providers
    # Provides access to macro-style method calls (e.g., validates, has_many) within a declaration.
    module MacrosProvider
      # @return [Rubyzen::Collections::MacrosCollection] collection of macro declarations
      def macros
        macros_nodes = node.each_descendant(:send).select(&:macro?)

        macros_declarations = macros_nodes.map do |macro_node|
          Rubyzen::Declarations::MacroDeclaration.new(macro_node, self)
        end

        Rubyzen::Collections::MacrosCollection.new(macros_declarations)
      end
    end
  end
end
