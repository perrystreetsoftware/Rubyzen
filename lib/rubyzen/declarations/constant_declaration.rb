require_relative '../providers/file_path_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/class_name_provider'
require_relative '../providers/source_code_provider'

module Rubyzen
  module Declarations
    class ConstantDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::SourceCodeProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def name
        case node.type
        when :casgn
          node.children[1].to_s
        when :const
          node.const_name
        end
      end

      def value
        return nil unless assignment?
        
        value_node = node.children[2]
        return nil unless value_node
        
        case value_node.type
        when :str
          value_node.str_content
        when :int
          value_node.children[0]
        when :float
          value_node.children[0]
        when :true, :false
          value_node.type == :true
        else
          value_node.source
        end
      end

      def assignment?
        node.type == :casgn
      end

      def reference?
        node.type == :const
      end

      def top_level?
        return false unless parent.is_a?(Rubyzen::Declarations::FileDeclaration)
        
        current_node = node
        while current_node
          current_node = current_node.parent
          return false if current_node && (current_node.type == :class || current_node.type == :module)
        end
        
        true
      end

      def in_class?
        find_parent_of_type(Rubyzen::Declarations::ClassDeclaration)
      end

      def in_module?
        find_parent_of_type(Rubyzen::Declarations::ModuleDeclaration)
      end

      def scoped?
        !top_level?
      end

      private

      def find_parent_of_type(type)
        current = parent
        while current
          return current if current.is_a?(type)
          current = current.respond_to?(:parent) ? current.parent : nil
        end
        nil
      end
    end
  end
end
