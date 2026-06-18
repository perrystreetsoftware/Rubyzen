module Rubyzen
  module Declarations
    # Represents a Ruby block (+do...end+ or +{ }+).
    #
    # @example
    #   block = method.blocks.first
    #   block.method_name   #=> "each"
    #   block.call_sites    #=> CallSiteCollection
    #   block.lines_of_code #=> 5
    #
    class BlockDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::RescuesProvider
      include Rubyzen::Providers::RaisesProvider
      include Rubyzen::Providers::SourceCodeProvider
      include Rubyzen::Providers::CallSiteProvider
      include Rubyzen::Providers::ReturnExpressionsProvider
      include Rubyzen::Providers::AssignmentsProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [MethodDeclaration, FileDeclaration]
      attr_reader :parent

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent [MethodDeclaration, FileDeclaration] the parent declaration
      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      # Returns the method name the block is passed to. Alias for {#method_name}.
      #
      # @return [String]
      def name
        method_name
      end

      # Returns the method name the block is passed to.
      #
      # @return [String] e.g. +"each"+, +"map"+, +"let"+
      def method_name
        node.method_name.to_s
      end
    end
  end
end
