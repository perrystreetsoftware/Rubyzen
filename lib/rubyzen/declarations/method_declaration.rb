module Rubyzen
  module Declarations
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

      attr_reader :node, :parent_class
      alias :parent :parent_class

      def initialize(node, parent_class)
        @node = node
        @parent_class = parent_class
      end

      def name
        node.method_name.to_s
      end

      def parameters
        node.arguments
      end

      def parameters?
        node.arguments.any?
      end

    end
  end
end
