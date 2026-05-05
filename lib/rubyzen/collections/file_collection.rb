
module Rubyzen
  module Collections
    # Collection of parsed file declarations. Serves as the top-level entry point
    # for navigating into classes, modules, constants, and other code elements.
    #
    # @example Getting all controller classes
    #   project.files.with_paths('src/controllers/').classes
    class FileCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Filters files whose path includes any of the given substrings.
      #
      # @param paths [Array<String>] path substrings to match
      # @return [FileCollection]
      def with_paths(*paths)
        filter do |file_declaration|
          paths.any? { |p| file_declaration.path.include?(p) }
        end
      end

      # Excludes files whose path includes any of the given substrings.
      #
      # @param paths [Array<String>] path substrings to exclude
      # @return [FileCollection]
      def without_paths(*paths)
        filter do |file_declaration|
          !paths.any? { |p| file_declaration.path.include?(p) }
        end
      end

      # Returns all class declarations across every file.
      #
      # @return [ClassesCollection]
      def classes
        all_classes = flat_map(&:classes)
        ClassesCollection.new(all_classes)
      end

      # Returns all module declarations across every file.
      #
      # @return [ModulesCollection]
      def modules
        all_modules = flat_map(&:modules)
        ModulesCollection.new(all_modules)
      end

      # Returns all constant declarations across every file.
      #
      # @return [ConstantsCollection]
      def constants
        all_constants = flat_map(&:constants)
        ConstantsCollection.new(all_constants)
      end

      # Returns all require/require_relative/load statements across every file.
      #
      # @return [RequiresCollection]
      def requires
        all_requires = flat_map(&:requires)
        RequiresCollection.new(all_requires)
      end

      # Returns all call sites across every file.
      #
      # @return [CallSiteCollection]
      def call_sites
        all_call_sites = flat_map(&:call_sites)
        CallSiteCollection.new(all_call_sites)
      end

      # Returns all block declarations across every file.
      #
      # @return [BlocksCollection]
      def blocks
        all_blocks = flat_map(&:blocks)
        BlocksCollection.new(all_blocks)
      end
    end
  end
end
