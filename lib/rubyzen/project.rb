
module Rubyzen
  class Project
    def initialize(paths = nil)
      paths ||= Rubyzen.configuration.project_paths
      @root_paths = Array(paths)

      @file_paths = @root_paths.flat_map do |path|
        if File.directory?(path)
          Dir[File.join(path, '**', '*.rb')]
        else
          [path]
        end
      end.uniq

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
