require_relative '../declarations/attribute_declaration'
require_relative '../collections/attributes_collection'

module Rubyzen
  module Providers
    module AttributesProvider
      def attributes
        attribute_nodes = node.each_descendant(:send).select do |send_node|
          %w[attr_reader attr_writer attr_accessor].include?(send_node.method_name.to_s)
        end

        attribute_declarations = attribute_nodes.map do |attr_node|
          Rubyzen::Declarations::AttributeDeclaration.new(attr_node, self)
        end

        Rubyzen::Collections::AttributesCollection.new(attribute_declarations)
      end
    end
  end
end
