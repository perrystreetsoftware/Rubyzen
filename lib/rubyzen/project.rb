module Rubyzen
  # Main entry point for analyzing a Ruby project. Parses all +.rb+ files
  # in the given paths and provides access to files, classes, and modules.
  #
  # @example Analyzing specific directories
  #   project = Rubyzen::Project.new(["app/models", "app/controllers"])
  #   project.files.with_paths("controllers/").classes
  #
  # @example Using auto-discovery
  #   project = Rubyzen::Project.new  # scans app/, lib/, src/, spec/
  #   project.classes.with_name("UsersController")
  #
  class Project
    # @param paths [String, Array<String>, nil] directories or file paths to analyze.
    #   Falls back to {Configuration#project_paths} (auto-discovery) if nil.
    def initialize(paths = nil)
      paths ||= Rubyzen.configuration.project_paths
      @root_paths = Array(paths).map { |p| File.expand_path(p) }

      @root_paths.each do |path|
        unless File.exist?(path)
          raise Rubyzen::Error, "Path does not exist: #{path}"
        end
      end

      @file_paths = @root_paths.flat_map do |path|
        if File.directory?(path)
          Dir[File.join(path, '**', '*.rb')]
        else
          [path]
        end
      end.uniq

      @parser = Rubyzen::Parsers::ASTParser.instance
    end

    # Returns all parsed files as a filterable collection.
    #
    # @return [Collections::FileCollection]
    def files
      all_files = file_declarations
      Collections::FileCollection.new(all_files)
    end

    # Returns all classes found across all parsed files.
    #
    # @return [Collections::ClassesCollection]
    def classes
      all_classes = file_declarations.flat_map(&:classes)
      Collections::ClassesCollection.new(all_classes)
    end

    # Returns all modules found across all parsed files.
    #
    # @return [Collections::ModulesCollection]
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
