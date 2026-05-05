require_relative '../providers/file_path_provider'
require_relative '../providers/line_number_provider'

module Rubyzen
  module Declarations
    # Represents a +require+, +require_relative+, or +load+ statement.
    #
    # @example
    #   req = file.requires.first
    #   req.required_path     #=> "json"
    #   req.require?          #=> true
    #   req.require_relative? #=> false
    #
    class RequireDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [FileDeclaration]
      attr_reader :parent_file
      alias :parent :parent_file

      # @param node [RuboCop::AST::Node] the AST node
      # @param parent_file [FileDeclaration] the parent file declaration
      def initialize(node, parent_file)
        @node = node
        @parent_file = parent_file
      end

      # Returns the statement type.
      #
      # @return [String] one of +"require"+, +"require_relative"+, +"load"+
      def name
        node.method_name.to_s
      end

      # Returns the required path string.
      #
      # @return [String, nil]
      def required_path
        first_arg = node.arguments.first
        return nil unless first_arg&.type == :str
        first_arg.value
      end

      # @return [Boolean]
      def require?
        name == 'require'
      end

      # @return [Boolean]
      def require_relative?
        name == 'require_relative'
      end

      # @return [Boolean]
      def load?
        name == 'load'
      end
    end
  end
end
