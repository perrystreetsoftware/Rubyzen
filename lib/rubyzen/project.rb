module Rubyzen
  class Project
    ClassInfo = Struct.new(
      :name,
      :constants_referenced,
      :file_path,
      :method_names,
      :top_level_module,
      :called_method_names,
      :call_sites,
      keyword_init: true
    )

    def initialize(path = nil)
      path ||= File.expand_path('../../../sample_project/src', __FILE__)
      @root_path = path
      @file_paths = if File.directory?(path)
                      Dir[File.join(path, '**', '*.rb')]
                    else
                      [path]
                    end
    end

    def classes
      class_infos = @file_paths.flat_map do |file_path|
        source = File.read(file_path)
        processed_source = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f, file_path)
        next [] unless processed_source.ast
        analyzer = ClassAnalyzer.new(processed_source)
        analyzer.analyze
      end
      ClassesCollection.new(class_infos)
    end

    def classes_with_name_ending_with(suffix)
      ClassesCollection.new(classes.select { |c| c.name&.end_with?(suffix) })
    end

    def classes_in_path(subpath)
      ClassesCollection.new(classes.select { |c| c.file_path.include?(subpath) })
    end

    def files_in_path(subpath)
      @file_paths.select { |f| f.include?(subpath) }
    end

    def classes_without_path(subpath)
      ClassesCollection.new(classes.reject { |c| c.file_path.include?(subpath) })
    end

    def line_count_for(file_path)
      full_path = @file_paths.find { |fp| fp.include?(file_path) }
      return 0 unless full_path && File.exist?(full_path)

      File.readlines(full_path).size
    end

    def file_path(relative_path)
      full_path = File.join(@root_path, relative_path)
      if File.exist?(full_path)
        full_path
      else
        raise "File #{relative_path} not found under #{@root_path}"
      end
    end
  end
end
