module Rubyzen
  module Declarations
    class BlockDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::RescuesProvider
      include Rubyzen::Providers::RaisesProvider
      include Rubyzen::Providers::SourceCodeProvider
      include Rubyzen::Providers::CallSiteProvider

      attr_reader :node, :parent

      def initialize(node, parent)
        @node = node
        @parent = parent
      end

      def name
        method_name
      end

      def method_name
        node.method_name.to_s
      end
    end
  end
end
