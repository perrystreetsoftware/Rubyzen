
module Rubyzen
  module Collections
    class CallSiteCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      def with_receiver(receiver)
        filter { |call_site| call_site.receiver == receiver }
      end

      def with_method_name(method_name)
        filter { |call_site| call_site.method_name == method_name }
      end
    end
  end
end
