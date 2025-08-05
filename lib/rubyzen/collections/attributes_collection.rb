require_relative 'base_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    class AttributesCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      def readers
        filter(&:reader?)
      end

      def writers
        filter(&:writer?)
      end

      def accessors
        filter(&:accessor?)
      end
    end
  end
end
