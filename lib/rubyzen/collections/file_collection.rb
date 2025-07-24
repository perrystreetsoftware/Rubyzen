require_relative 'classes_collection'

module Rubyzen
  module Collections
    class FileCollection < BaseCollection
      def files_in_path(subpath)
        filter { |file_declaration| file_declaration.path.include?(subpath) }
      end

      def files_with_name_ending_with(suffix)
        filter do |file_declaration|
          File.basename(file_declaration.path).end_with?(suffix)
        end
      end

      def files_with_name_including(substr)
        filter do |file_declaration|
          File.basename(file_declaration.path).include?(substr)
        end
      end

      def excluding_files(*paths)
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
