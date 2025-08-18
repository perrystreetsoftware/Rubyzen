require_relative 'base_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    class ModulesCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      def classes
        all_classes = flat_map(&:classes)
        ClassesCollection.new(all_classes)
      end

      def constants
        all_constants = flat_map(&:constants)
        ConstantsCollection.new(all_constants)
      end
    end
  end
end
