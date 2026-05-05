module Rubyzen
  module Providers
    # Provides access to method call sites within a declaration.
    module CallSiteProvider
      # @return [Rubyzen::Collections::CallSiteCollection] collection of call site declarations
      def call_sites
        Collections::CallSiteCollection.new(
          node.each_descendant(:send).map do |send_node|
            Declarations::CallSiteDeclaration.new(send_node, self)
          end
        )
      end
    end
  end
end
