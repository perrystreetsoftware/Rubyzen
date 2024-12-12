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
  end
end
