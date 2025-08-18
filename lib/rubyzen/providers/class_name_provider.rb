module Rubyzen
  module Providers
    module ClassNameProvider
      def class_name
        class_name_recursive(self)
      end

      private

      def class_name_recursive(declaration)
        return if declaration.nil?
        return declaration.name if declaration.is_a?(Rubyzen::Declarations::ClassDeclaration)
        return nil if declaration.is_a?(Rubyzen::Declarations::FileDeclaration)
        return class_name_recursive(declaration.parent) if declaration.respond_to?(:parent)
      end
    end
  end
end
