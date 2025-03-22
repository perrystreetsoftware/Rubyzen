require_relative 'parsers/ast_parser'

module Rubyzen
  class Project
    ClassInfo = Struct.new(
      :name,
      :superclass_name,
      :constants_referenced,
      :file_path,
      :method_names,
      :top_level_module,
      :called_method_names,
      :call_sites,
      keyword_init: true
    )

    def initialize(path = nil)
      path ||= Rubyzen.configuration.project_root_path
      @root_path = path
      @file_paths = if File.directory?(path)
                      Dir[File.join(path, '**', '*.rb')]
                    else
                      [path]
                    end
      @parser = Rubyzen::Parsers::ASTParser.new
    end

    def classes
      all_classes = file_declarations.flat_map(&:classes)
      ClassesCollection.new(
        all_classes.map do |klass|
          ClassInfo.new(
            name: klass.name,
            superclass_name: klass.superclass_name,
            constants_referenced: klass.constants_referenced,
            file_path: klass.file_path,
            method_names: klass.methods.map(&:name),
            top_level_module: klass.top_level_module,
            called_method_names: klass.called_method_names,
            call_sites: klass.call_sites
          )
        end
      )
    end

    def classes_with_name_ending_with(suffix)
      classes.classes_with_name_ending_with(suffix)
    end

    def classes_in_path(subpath)
      classes.classes_in_path(subpath)
    end

    def classes_inheriting_from(superclass)
      classes.classes_inheriting_from(superclass)
    end

    def classes_that_call_method(receiver, method_name)
      receiver = receiver.to_s
      method_name = method_name.to_s
      classes.select do |class_info|
        class_info.call_sites.any? do |call_site|
          call_site[:receiver] == receiver && call_site[:method_name] == method_name
        end
      end
    end

    def files_in_path(subpath)
      @file_paths.select { |f| f.include?(subpath) }
    end

    def classes_without_path(subpath)
      classes.classes_without_path(subpath)
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

    private

    def file_declarations
      @file_paths.map { |path| @parser.parse_file(path) }.compact
    end
  end
end
