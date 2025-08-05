require_relative 'parsers/ast_parser'
require_relative 'collections/file_collection'
require_relative 'collections/classes_collection'

module Rubyzen
  class Project
    def initialize(path = nil, exclude_relative_paths: [])
      path ||= Rubyzen.configuration.project_root_path
      @root_path = path
      @file_paths = if File.directory?(path)
                       Dir[File.join(path, '**', '*.rb')]
                     else
                       [path]
                     end
      @excluded_paths = exclude_relative_paths.map do |exclude_path|
        if File.directory?(exclude_path)
          Dir[File.join(path, exclude_path, '**', '*.rb')]
        else
          [File.join(path, exclude_path)]
        end
      end.flatten.uniq.compact
      
      @parser = Rubyzen::Parsers::ASTParser.instance
    end

    def files
      all_files = file_declarations
      Collections::FileCollection.new(all_files)
    end

    def classes
      all_classes = file_declarations.flat_map(&:classes)
      Collections::ClassesCollection.new(all_classes)
    end

    private

    def file_declarations
      @file_declarations ||= (@file_paths - @excluded_paths).map do |file_path|
        @parser.parse_file(file_path)
      end.compact
    end
  end
end
