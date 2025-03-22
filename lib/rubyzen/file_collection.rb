require_relative 'classes_collection'

module Rubyzen
  class FileCollection < Array
    def initialize(file_declarations)
      super(file_declarations)
    end

    def files_in_path(subpath)
      filtered = select { |file_declaration| file_declaration.path.include?(subpath) }
      FileCollection.new(filtered)
    end

    def files_with_name_ending_with(suffix)
      filtered = select do |file_declaration|
        File.basename(file_declaration.path).end_with?(suffix)
      end
      FileCollection.new(filtered)
    end

    def files_with_name_including(substr)
      filtered = select do |file_declaration|
        File.basename(file_declaration.path).include?(substr)
      end
      FileCollection.new(filtered)
    end

    def excluding_files(paths)
      paths = Array(paths).map(&:to_s)
      filtered = reject do |file_declaration|
        paths.any? { |p| file_declaration.path.include?(p) }
      end
      FileCollection.new(filtered)
    end

    def classes
      all_classes = flat_map(&:classes)
      ClassesCollection.new(all_classes)
    end
  end
end
