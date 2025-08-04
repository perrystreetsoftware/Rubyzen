require_relative 'parsers/ast_parser'
require_relative 'collections/file_collection'
require_relative 'collections/classes_collection'
require_relative 'collections/modules_collection'

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
      Collections::FileCollection.new(all_files)
    end

    def classes
      all_classes = file_declarations.flat_map(&:classes)
      Collections::ClassesCollection.new(all_classes)
    end

    def modules
      all_modules = file_declarations.flat_map(&:modules)
      Collections::ModulesCollection.new(all_modules)
    end

    private

    def file_declarations
      @file_declarations ||= @file_paths.map do |file_path|
        @parser.parse_file(file_path)
      end.compact
    end
  end
end
