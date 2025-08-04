require_relative './methods_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    class ClassesCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider
      
      undef_method(:methods)

      def all_methods
        instance_plus_class_methods = flat_map { |klass| klass.instance_methods + klass.class_methods }
        MethodsCollection.new(instance_plus_class_methods)
      end

      def with_parent_prefix(prefix)
        filter { |klass| klass.superclass_prefix?(prefix) }
      end

      end

      def +(other)
        merged = super(other)
        self.class.new(merged)
      end
    end
  end
end
