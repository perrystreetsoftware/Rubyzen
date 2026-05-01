
module Rubyzen
  module Collections
    # Collection of method call sites found in classes, methods, or blocks.
    #
    # @example Ensuring controllers do not call .where directly
    #   expect(controllers.that { have_call_sites_with_names('.where') }).to be_empty
    class CallSiteCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Filters call sites by the receiver expression.
      #
      # @param receiver [String] the receiver to match
      # @return [CallSiteCollection]
      def with_receiver(receiver)
        filter { |call_site| call_site.receiver == receiver }
      end

      # Filters call sites by method name.
      #
      # @param name [String] the method name to match
      # @return [CallSiteCollection]
      def with_name(name)
        filter { |call_site| call_site.name == name }
      end

      # Alias for {#with_name}.
      #
      # @param method_name [String] the method name to match
      # @return [CallSiteCollection]
      def with_method_name(method_name)
        with_name(method_name)
      end

      # Filters call sites that include the given symbol argument.
      #
      # @param symbol [Symbol] the symbol argument to match
      # @return [CallSiteCollection]
      def with_symbol(symbol)
        filter { |call_site| call_site.symbols.include?(symbol) }
      end

      # Filters call sites that include the given keyword argument.
      #
      # @param keyword_arg [Symbol] the keyword argument to match
      # @return [CallSiteCollection]
      def with_keyword_arg(keyword_arg)
        filter { |call_site| call_site.keyword_args.include?(keyword_arg) }
      end
    end
  end
end
