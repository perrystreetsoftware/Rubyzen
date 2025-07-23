require_relative '../declarations/block_declaration'
require_relative '../declarations/class_declaration'

module Rubyzen
  module Providers
    module ClassNameProvider
      def class_name
        class_name_recursive(self)
      end

      private

      def class_name_recursive(declaration)
        return if declaration.nil?
        return declaration.name_with_modules if declaration.is_a?(Rubyzen::Declarations::ClassDeclaration)
        return class_name_recursive(declaration.parent) if declaration.respond_to?(:parent)
      end
    end
  end
end
