module Rubyzen
  module Declarations
    # Represents a method call site (a +send+ node in the AST).
    #
    # @example
    #   call_site = method.call_sites.first
    #   call_site.method_name   #=> "find"
    #   call_site.receiver      #=> "User"
    #   call_site.keyword_args  #=> [:id, :name]
    #
    class CallSiteDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::SourceCodeProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [MethodDeclaration, BlockDeclaration, FileDeclaration]
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent [MethodDeclaration, BlockDeclaration, FileDeclaration] the parent declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns the called method name. Alias for {#method_name}.
      #
      # @return [String]
      def name
        method_name
      end

      # Returns the constant name of the receiver, if any.
      #
      # @return [String, nil] e.g. +"User"+ for +User.find(1)+, +nil+ for +save+
      def receiver
        node.receiver&.type == :const ? node.receiver.const_name : nil
      end

      # Returns the called method name.
      #
      # @return [String]
      def method_name
        node.method_name.to_s
      end

      # Returns the keyword argument keys passed in the call.
      #
      # @return [Array<Symbol>] e.g. +[:level, :details]+
      def keyword_args
        node.arguments.flat_map do |arg|
          next [] unless arg.hash_type?

          arg.pairs.filter_map do |pair|
            pair.key.value if pair.key.type == :sym
          end
        end.uniq
      end

      # Returns a hash mapping keyword argument keys to their literal values.
      #
      # @return [Hash{Symbol => Object}] values are +nil+ for non-literal expressions
      def keyword_arg_value_pairs
        result = {}
        node.arguments.each do |arg|
          next unless arg.hash_type?

          arg.pairs.each do |pair|
            next unless pair.key.type == :sym

            value_node = pair.value
            result[pair.key.value] = value_node.respond_to?(:value) ? value_node.value : nil
          end
        end
        result
      end

      # Returns positional symbol arguments.
      #
      # @return [Array<Symbol>] e.g. +[:name, :email]+
      def symbols
        node.arguments.select { |arg| arg.type == :sym }.map(&:value)
      end

      # Returns positional string arguments.
      #
      # @return [Array<String>]
      def strings
        node.arguments.select { |arg| arg.type == :str }.map(&:value)
      end

    end
  end
end
