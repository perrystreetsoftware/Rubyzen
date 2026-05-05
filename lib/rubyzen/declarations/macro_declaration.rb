module Rubyzen
  module Declarations
    # Represents a class-level macro call (e.g. +validates_required+, +belongs_to+).
    #
    # @example
    #   macro = klass.macros.first
    #   macro.name          #=> "validates_required"
    #   macro.symbols       #=> [:name, :email]
    #   macro.keyword_args  #=> [:foreign_key, :optional]
    #
    class MacroDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::SourceCodeProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [ClassDeclaration]
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent [ClassDeclaration] the parent declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns the macro method name.
      #
      # @return [String] e.g. +"validates_required"+, +"belongs_to"+
      def name
        node.method_name.to_s
      end

      # Returns positional symbol arguments.
      #
      # @return [Array<Symbol>]
      def symbols
        node.arguments.select { |arg| arg.type == :sym }.map(&:value)
      end

      # Returns positional string arguments.
      #
      # @return [Array<String>]
      def strings
        node.arguments.select { |arg| arg.type == :str }.map(&:value)
      end

      # Returns keyword argument keys.
      #
      # @return [Array<Symbol>]
      def keyword_args
        extract_keyword_args(node)
      end

      # Returns the constant receiver, if any.
      #
      # @return [String, nil] e.g. +"Config"+ for +Config.setting+
      def receiver
        node.receiver&.type == :const ? node.receiver.const_name : nil
      end

      private

      def extract_keyword_args(send_node)
        send_node.arguments.flat_map do |arg|
          if arg.hash_type?
            arg.each_pair.map do |pair|
              key_node = pair.key
              key_node.type == :sym ? key_node.value : nil
            end.compact
          else
            []
          end
        end.uniq
      end
    end
  end
end
