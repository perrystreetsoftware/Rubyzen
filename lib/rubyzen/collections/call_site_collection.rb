require_relative './base_collection'

module Rubyzen
  module Collections
    class CallSiteCollection < BaseCollection
      def with_receiver(receiver)
        filter { |call_site| call_site.receiver == receiver }
      end

      def with_method_name(method_name)
        filter { |call_site| call_site.method_name == method_name }
      end
    end
  end
end
