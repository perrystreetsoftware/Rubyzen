require_relative 'methods_collection'

module Rubyzen
  class ClassesCollection < Array
    def initialize(class_declarations)
      super(class_declarations)
    end

    def all_methods
      instance_plus_class_methods = flat_map(&:instance_methods) #+ flat_map(&:class_methods)
      MethodsCollection.new(instance_plus_class_methods)
    end

    def classes_in_path(subpath)
      filtered = select { |cd|
       cd.file_path&.include?(subpath)
      }
      ClassesCollection.new(filtered)
    end

    def classes_without_path(subpath)
      filtered = reject { |cd| cd.file_path.include?(subpath) }
      ClassesCollection.new(filtered)
    end

    def classes_inheriting_from(superclass)
      filtered = case superclass
                 when Proc
                   select { |cd| superclass.call(cd.superclass_name) }
                 when String
                   select { |cd| cd.superclass_name == superclass }
                 else
                   raise ArgumentError, "Expected a String or Proc, got #{superclass.class}"
                 end

      ClassesCollection.new(filtered)
    end

    def classes_with_name_ending_with(suffix)
      filtered = select { |cd| cd.name&.end_with?(suffix) }
      ClassesCollection.new(filtered)
    end

    def excluding_classes(class_names)
      class_names = Array(class_names).map { |cn| cn.to_s.sub(/^:/, '') }
      filtered = reject { |cd| class_names.include?(cd.name) }
      ClassesCollection.new(filtered)
    end

    def excluding_classes_by_path(path_names)
      filtered = reject do |cd|
        path_names.any? do |path_name|
          cd.file_path.to_s.end_with?(path_name)
        end
      end

      ClassesCollection.new(filtered)
    end
  end
end
