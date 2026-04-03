module Rubyzen
  module Collections
    class BlocksCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      def with_method_name(method_name)
        filter { |block| block.method_name == method_name }
      end

      def call_sites
        all_call_sites = flat_map(&:call_sites)
        CallSiteCollection.new(all_call_sites)
      end
    end
  end
end
