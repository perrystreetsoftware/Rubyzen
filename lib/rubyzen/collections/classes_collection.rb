
module Rubyzen
  module Collections
    class ClassesCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      undef_method(:methods)

      def all_methods
        instance_plus_class_methods = flat_map { |klass| klass.instance_methods + klass.class_methods }
        MethodsCollection.new(instance_plus_class_methods)
      end

      def attributes
        all_attributes = flat_map(&:attributes)
        AttributesCollection.new(all_attributes)
      end

      def with_parent_prefix(prefix)
        filter { |klass| klass.superclass_prefix?(prefix) }
      end

      def +(other)
        merged = super(other)
        self.class.new(merged)
      end
    end
  end
end
