require_relative '../providers/file_path_provider'
require_relative '../providers/class_name_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/visibility_provider'

module Rubyzen
  module Declarations
    # Represents an +attr_reader+, +attr_writer+, or +attr_accessor+ declaration.
    #
    # @example
    #   attr = klass.attributes.first
    #   attr.name      #=> "attr_reader"
    #   attr.symbols   #=> ["name", "email"]
    #   attr.reader?   #=> true
    #   attr.private?  #=> false
    #
    class AttributeDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::VisibilityProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [ClassDeclaration, ModuleDeclaration]
      attr_reader :parent_class
      alias :parent :parent_class

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent_class [ClassDeclaration, ModuleDeclaration] the parent declaration
      def initialize(node, parent_class)
        @node = node
        @parent_class = parent_class
      end

      # Returns the attribute type name.
      #
      # @return [String] one of +"attr_reader"+, +"attr_writer"+, +"attr_accessor"+
      def name
        node.method_name.to_s
      end

      # Returns the declared symbol names.
      #
      # @return [Array<String>] e.g. +["name", "email"]+
      def symbols
        node.arguments.map { |arg| arg.value.to_s if arg.type == :sym }.compact
      end

      # @return [Boolean] true for +attr_reader+ and +attr_accessor+
      def reader?
        %w[attr_reader attr_accessor].include?(name)
      end

      # @return [Boolean] true for +attr_writer+ and +attr_accessor+
      def writer?
        %w[attr_writer attr_accessor].include?(name)
      end

      # @return [Boolean] true only for +attr_accessor+
      def accessor?
        name == 'attr_accessor'
      end
    end
  end
end
