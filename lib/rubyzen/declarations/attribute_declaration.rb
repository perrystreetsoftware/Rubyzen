require_relative '../providers/file_path_provider'
require_relative '../providers/class_name_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/visibility_provider'

module Rubyzen
  module Declarations
    class AttributeDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::VisibilityProvider

      attr_reader :node, :parent_class
      alias :parent :parent_class

      def initialize(node, parent_class)
        @node = node
        @parent_class = parent_class
      end

      def name
        node.method_name.to_s
      end

      def symbols
        node.arguments.map { |arg| arg.value.to_s if arg.type == :sym }.compact
      end

      def reader?
        %w[attr_reader attr_accessor].include?(name)
      end

      def writer?
        %w[attr_writer attr_accessor].include?(name)
      end

      def accessor?
        name == 'attr_accessor'
      end
    end
  end
end
