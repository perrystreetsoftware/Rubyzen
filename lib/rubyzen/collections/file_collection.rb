require_relative 'classes_collection'
require_relative 'modules_collection'
require_relative 'constants_collection'
require_relative 'requires_collection'
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

      def modules
        all_modules = flat_map(&:modules)
        ModulesCollection.new(all_modules)
      end

      def constants
        all_constants = flat_map(&:constants)
        ConstantsCollection.new(all_constants)
      end

      def requires
        all_requires = flat_map(&:requires)
        RequiresCollection.new(all_requires)
      end
    end
  end
end
