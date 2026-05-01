require_relative 'base_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    # Collection of module declarations with methods for navigating into
    # child elements (methods, classes, constants).
    #
    # @example Getting all methods defined in modules
    #   project.files.modules.all_methods
    class ModulesCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Returns all methods defined across every module.
      #
      # @return [MethodsCollection]
      def all_methods
        all_methods = flat_map(&:all_methods)
        MethodsCollection.new(all_methods)
      end

      # Returns all class declarations nested inside every module.
      #
      # @return [ClassesCollection]
      def classes
        all_classes = flat_map(&:classes)
        ClassesCollection.new(all_classes)
      end

      # Returns all constant declarations across every module.
      #
      # @return [ConstantsCollection]
      def constants
        all_constants = flat_map(&:constants)
        ConstantsCollection.new(all_constants)
      end
    end
  end
end
