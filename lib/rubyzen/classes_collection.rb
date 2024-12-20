require_relative 'methods_collection'

module Rubyzen
  class ClassesCollection < Array
    def initialize(class_infos)
      super(class_infos)
    end

    def methods
      all_method_names = flat_map { |c| c.method_names || [] }
      MethodsCollection.new(all_method_names)
    end

    def classes_in_path(subpath)
      filtered = select { |c| c.file_path.include?(subpath) }
      ClassesCollection.new(filtered)
    end

    def classes_without_path(subpath)
      filtered = reject { |c| c.file_path.include?(subpath) }
      ClassesCollection.new(filtered)
    end

    def classes_inheriting_from(superclass)
      filtered = case superclass
                 when Proc
                   select { |c| superclass.call(c.superclass_name) }
                 when String
                   select { |c| c.superclass_name == superclass }
                 else
                   raise ArgumentError, "Expected a String or Proc, got #{superclass.class}"
                 end
    
      ClassesCollection.new(filtered)
    end

    def classes_with_name_ending_with(suffix)
      filtered = select { |c| c.name&.end_with?(suffix) }
      ClassesCollection.new(filtered)
    end

    def excluding_classes(class_names)
      class_names = Array(class_names).map { |cn| cn.to_s.sub(/^:/, '') }
      filtered = reject { |c| class_names.include?(c.name) }
      ClassesCollection.new(filtered)
    end
  end
end
