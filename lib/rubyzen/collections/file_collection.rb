require_relative 'classes_collection'

module Rubyzen
  module Collections
    class FileCollection < BaseCollection
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
    end
  end
end
