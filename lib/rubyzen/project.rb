require_relative 'parsers/ast_parser'
require_relative 'collections/file_collection'
require_relative 'collections/classes_collection'

module Rubyzen
  class Project
    def initialize(path = nil)
      path ||= Rubyzen.configuration.project_root_path
      @root_path = path
      @file_paths = if File.directory?(path)
                       Dir[File.join(path, '**', '*.rb')]
                     else
                       [path]
                     end
      @parser = Rubyzen::Parsers::ASTParser.instance
    end

    def files
      all_files = file_declarations
      FileCollection.new(all_files)
    end

    def classes
      all_classes = file_declarations.flat_map(&:classes)
      Collections::ClassesCollection.new(all_classes)
    end

    # def classes_with_name_ending_with(suffix)
    #   classes.classes_with_name_ending_with(suffix)
    # end

    # def inheriting_from(superclass)
    #   classes.inheriting_from(superclass)
    # end

    def files_in_path(subpath)
      files.files_in_path(subpath).map(&:path)
    end

    def line_count_for(relative_path)
      fp = @file_paths.find { |p| p.include?(relative_path) }
      return 0 unless fp && File.exist?(fp)
      File.readlines(fp).size
    end

    def file_path(relative_path)
      full_path = File.join(@root_path, relative_path)
      if File.exist?(full_path)
        full_path
      else
        raise "File #{relative_path} not found under #{@root_path}"
      end
    end

    private

    def file_declarations
      @file_declarations ||= @file_paths.map do |file_path|
        @parser.parse_file(file_path)
      end.compact
    end
  end
end
