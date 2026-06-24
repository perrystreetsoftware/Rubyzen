module Rubyzen
  module Declarations
    # Represents a Ruby method definition (+def+ or +def self.+).
    #
    # @example
    #   method = klass.instance_methods.first
    #   method.name          #=> "calculate"
    #   method.parameters?   #=> true
    #   method.call_sites    #=> CallSiteCollection
    #   method.visibility    #=> :private
    #
    class MethodDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ConstantsProvider
      include Rubyzen::Providers::CallSiteProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::VisibilityProvider
      include Rubyzen::Providers::RescuesProvider
      include Rubyzen::Providers::RaisesProvider
      include Rubyzen::Providers::ReturnsProvider
      include Rubyzen::Providers::AssignmentsProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [ClassDeclaration, ModuleDeclaration]
      attr_reader :parent_class
      alias :parent :parent_class

      def initialize(node, parent_class)
        @node = node
        @parent_class = parent_class
      end

      # Returns the method name.
      #
      # @return [String]
      def name
        node.method_name.to_s
      end

      # Returns the method's parameters.
      #
      # @return [Collections::ParametersCollection]
      def parameters
        Collections::ParametersCollection.new(
          node.arguments.map do |arg|
            ParameterDeclaration.new(arg, self)
          end
        )
      end

      # Returns whether this method has any parameters.
      #
      # @return [Boolean]
      def parameters?
        node.arguments.any?
      end
    end
  end
end
