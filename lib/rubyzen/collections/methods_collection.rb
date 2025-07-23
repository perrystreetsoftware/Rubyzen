module Rubyzen
  module Collections
    class MethodsCollection < BaseCollection
      def names
        map(&:name)
      end

      def if_statements
        DeclarationCollection.new(
          flat_map do |method|
            method.if_statements
          end
        )
      end

      def call_sites
        CallSiteCollection.new(
          flat_map do |method|
            method.call_sites
          end
        )
      end
    end
  end
end
