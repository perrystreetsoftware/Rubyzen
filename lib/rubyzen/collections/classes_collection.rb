require_relative './methods_collection'

module Rubyzen
  module Collections
    class ClassesCollection < BaseCollection
      undef_method(:methods)

      def all_methods
        instance_plus_class_methods = flat_map { |klass| klass.instance_methods + klass.class_methods }
        MethodsCollection.new(instance_plus_class_methods)
      end

      def with_parent_prefix(prefix)
        filter { |klass| klass.superclass_prefix?(prefix) }
      end

      def with_name_ending_with(suffix)
        filter { |cd| cd.name&.end_with?(suffix) }
      end

      def without_name_ending_with(suffix)
        filter { |cd| !cd.name&.end_with?(suffix) }
      end

      def without_name(*class_names)
        filter { |cd| !class_names.include?(cd.name_with_modules) }
      end

      def +(other)
        merged = super(other)
        self.class.new(merged)
      end
    end
  end
end
