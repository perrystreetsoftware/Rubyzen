require_relative 'base_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    class MethodsCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      def parameters
        ParametersCollection.new(
          flat_map do |method|
            method.parameters
          end
        )
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

      def rescues
        RescuesCollection.new(
          flat_map do |method|
            method.rescues
          end
        )
      end

      def raises
        RaisesCollection.new(
          flat_map do |method|
            method.raises
          end
        )
      end
    end
  end
end
