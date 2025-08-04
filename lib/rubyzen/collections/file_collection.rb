require_relative 'classes_collection'
require_relative 'constants_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    class FileCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider
      
      def with_paths(*paths)
        filter do |file_declaration|
          paths.any? { |p| file_declaration.path.include?(p) }
        end
      end

      def without_paths(*paths)
        filter do |file_declaration|
          !paths.any? { |p| file_declaration.path.include?(p) }
        end
      end

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
