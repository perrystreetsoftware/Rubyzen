require_relative 'method_declaration'
require_relative '../providers/if_statements_provider'
require_relative '../providers/blocks_provider'
require_relative '../providers/file_path_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/lines_of_code_provider'
require_relative '../providers/constants_provider'
require_relative '../providers/attributes_provider'
require_relative '../collections/methods_collection'

module Rubyzen
  module Declarations
    class ClassDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::ConstantsProvider
      include Rubyzen::Providers::AttributesProvider

      attr_reader :node, :file_declaration

      def initialize(node, file_declaration)
        @node = node
        @file_declaration = file_declaration
      end

      def name
        [file_declaration.modules.map(&:name), name_without_modules].flatten.compact.join('::')
      end

      def name_without_modules
        node.identifier&.const_name
      end

      def superclass_name
        super_node = node.children[1]
        return nil unless super_node&.type == :const
        super_node.const_name
      end

      def superclass_prefix?(prefix)
        superclass_name&.start_with?(prefix)
      end

      def instance_methods
        Collections::MethodsCollection.new(
          node.each_node(:def).map do |def_node|
            MethodDeclaration.new(def_node, self)
          end
        )
      end

      def class_methods
        Collections::MethodsCollection.new(
          node.each_node(:defs).map do |defs_node|
            MethodDeclaration.new(defs_node, self)
          end
        )
      end

      def called_method_names
        node.each_descendant(:send).map { |send_node| send_node.method_name.to_s }.uniq
      end

      def top_level_module
        file_declaration.top_level_module_name
      end
    end
  end
end
