module Rubyzen
  module Providers
    module CallSiteProvider
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
