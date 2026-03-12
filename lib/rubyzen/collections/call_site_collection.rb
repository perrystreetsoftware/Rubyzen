
module Rubyzen
  module Collections
    class CallSiteCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      def with_receiver(receiver)
        filter { |call_site| call_site.receiver == receiver }
      end

      def with_name(name)
        filter { |call_site| call_site.name == name }
      end

      def with_method_name(method_name)
        with_name(method_name)
      end

      def with_symbol(symbol)
        filter { |call_site| call_site.symbols.include?(symbol) }
      end

      def with_keyword_arg(keyword_arg)
        filter { |call_site| call_site.keyword_args.include?(keyword_arg) }
      end
    end
  end
end
