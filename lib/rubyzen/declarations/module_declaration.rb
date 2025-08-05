require_relative '../providers/file_path_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/class_name_provider'
require_relative '../providers/constants_provider'
require_relative '../providers/lines_of_code_provider'
require_relative '../providers/attributes_provider'
require_relative 'class_declaration'

module Rubyzen
  module Declarations
    class ModuleDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::ConstantsProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::AttributesProvider

      attr_reader :node, :file_declaration

      def initialize(node, file_declaration)
        @node = node
        @file_declaration = file_declaration
      end

      def name
        parent_module_names = []
        current_node = node.parent
        
        while current_node
          if current_node.type == :module
            parent_module_names.unshift(current_node.identifier&.const_name)
          end
          current_node = current_node.parent
        end
        
        [parent_module_names, name_without_modules].flatten.compact.join('::')
      end

      def name_without_modules
        node.identifier&.const_name
      end

      def modules
        node.each_node(:module).map { |mod_node| ModuleDeclaration.new(mod_node, file_declaration) }
      end

      def classes
        node.each_node(:class).map { |class_node| ClassDeclaration.new(class_node, file_declaration) }
      end
    end
  end
end
