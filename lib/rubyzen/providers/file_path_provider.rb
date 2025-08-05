module Rubyzen
  module Providers
    module FilePathProvider
      def file_path
        file_path_recursive(self)
      end

      private

      def file_path_recursive(declaration)
        return if declaration.nil?
        return declaration.path if declaration.respond_to?(:path)

        if declaration.respond_to?(:file_declaration)
          return file_path_recursive(declaration.file_declaration)
        elsif declaration.respond_to?(:parent)
          return file_path_recursive(declaration.parent)
        elsif declaration.respond_to?(:parent_class)
          return file_path_recursive(declaration.parent_class)
        end
      end
    end
  end
end
