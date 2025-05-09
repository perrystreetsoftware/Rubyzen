require_relative 'parsers/ast_parser'
require_relative 'file_collection'
require_relative 'classes_collection'

module Rubyzen
  class Project
    attr_accessor :root_path, :only_changed_files

    def initialize(path = nil)
      path ||= Rubyzen.configuration.project_root_path
      @only_changed_files = Rubyzen.configuration.only_changed_files

      @root_path = path
      @file_paths = if File.directory?(path)
                       Dir[File.join(path, '**', '*.rb')]
                     else
                       [path]
                     end
      @parser = Rubyzen::Parsers::ASTParser.instance
    end

    def files
      @files ||= begin
        all_files = file_declarations
        if only_changed_files
          changed_files = all_files.select do |file_decl|
            changed_filenames.include?(file_decl.path)
          end

          FileCollection.new(changed_files)
        else
          FileCollection.new(all_files)
        end
      end
    end

    def classes
      @classes ||= begin
        all_classes = file_declarations.flat_map(&:classes)

        # Create an index of classes by their full name for O(1) lookup
        class_index = all_classes.each_with_object({}) do |class_decl, index|
          index[class_decl.name_with_modules] = class_decl
        end

        # Now we can look up superclasses in constant time
        all_classes.each do |sub_class_decl|
          next unless sub_class_decl.superclass_name

          super_class_name = sub_class_decl.superclass_name_with_modules
          super_class_decl = class_index[super_class_name]
          next unless super_class_decl

          super_class_decl.subclasses << sub_class_decl
          sub_class_decl.super_class = super_class_decl
        end

        # only return classes that were changed in the PR
        # parent and subclasses can still be accessed even if they are not changed
        if only_changed_files
          classes_with_changes = select_only_changed_classes(all_classes)
          filenames = classes_with_changes.map(&:file_path).join("\n")
          puts "\nRunning only on files with changes:\n#{filenames}\n"

          ClassesCollection.new(classes_with_changes)
        else
          ClassesCollection.new(all_classes)
        end
      end
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

    # this does not find subclasses that inherit the called method from superclass
    def classes_that_call_method(receiver, method_name)
      classes.select do |class_decl|
        class_decl.call_sites.any? do |site|
          site[:receiver] == receiver.to_s && site[:method_name] == method_name.to_s
        end
      end
    end

    def files_in_path(subpath)
      files.files_in_path(subpath).map(&:path)
    end

    def classes_without_path(subpath)
      classes.classes_without_path(subpath)
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

    def select_only_changed_classes(classes)
      classes.select do |class_decl|
        changed_filenames.include?(class_decl.file_path)
      end
    end

    def select_only_changed_files(files)
      raise "This method is not implemented yet"

    end

    def changed_filenames
      @changed_filenames ||= begin
        cmd = <<~CMD
          cd #{root_path} && \
          git fetch origin && \
          { \
            # Committed adds & mods (no deletes)
            git diff --diff-filter=AM --name-only \
              origin/$(git remote show origin | sed -n 's/.*HEAD branch: //p')...$(git rev-parse --abbrev-ref HEAD) \
              -- '*.rb' ':(exclude)spec/**'; \
            # Unstaged modifications only
            git diff --diff-filter=M --name-only -- '*.rb' ':(exclude)spec/**'; \
            # Untracked new files
            git ls-files --others --exclude-standard -- '*.rb' ':(exclude)spec/**'; \
          } | sort -u
        CMD

        filenames = `#{cmd}`.split("\n").map(&:strip)
        filenames = filenames.map { |filename| "./#{filename}" }

        if filenames.first.start_with?(root_path)
          filenames
        else
          filenames.map do |filename|
            filename.sub("./src", root_path)
          end
        end
      end
    end

    def file_declarations
      @file_declarations ||= @file_paths.map do |file_path|
        @parser.parse_file(file_path)
      end.compact
    end
  end
end
