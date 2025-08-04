require_relative 'class_declaration'
require_relative '../providers/lines_of_code_provider'
require_relative '../providers/constants_provider'

module Rubyzen
  module Declarations
    class FileDeclaration
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::ConstantsProvider

      attr_reader :path, :node
      alias :ast :node

      def initialize(path, ast)
        @path = path
        @node = ast
      end

      def name
        File.basename(path)
      end

      def classes
        node.each_node(:class).map do |class_node|
          ClassDeclaration.new(class_node, self)
        end
      end

      def top_level_module_name
        modules.first&.name_without_modules
      end

      def modules
        node.each_node(:module).map do |module_node|
          Rubyzen::Declarations::ModuleDeclaration.new(module_node, self)
        end
      end
    end
  end
end
