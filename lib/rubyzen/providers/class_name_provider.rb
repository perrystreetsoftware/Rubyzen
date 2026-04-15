module Rubyzen
  module Providers
    module ClassNameProvider
      def class_name
        class_name_recursive(self)
      end

      private

      def class_name_recursive(declaration)
        return if declaration.nil?
        return nil if declaration.is_a?(Rubyzen::Declarations::FileDeclaration)
        return declaration.name if declaration.is_a?(Rubyzen::Declarations::ClassDeclaration)

        if declaration.is_a?(Rubyzen::Declarations::ModuleDeclaration)
          return module_class_name(declaration)
        end

        class_name_recursive(parent_declaration(declaration))
      end

      def module_class_name(declaration)
        parent_class_name = class_name_recursive(parent_declaration(declaration))
        parent_class_name || declaration.name
      end

      def parent_declaration(declaration)
        return unless declaration.respond_to?(:parent)

        declaration.parent
      end
    end
  end
end
