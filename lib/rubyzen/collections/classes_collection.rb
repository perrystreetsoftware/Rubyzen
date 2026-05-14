module Rubyzen
  module Collections
    # Collection of class declarations with methods for navigating into
    # child elements (methods, attributes, macros) and filtering by inheritance.
    #
    # @example Ensuring controllers inherit from ApplicationController
    #   expect(controllers.with_parent_prefix('ApplicationController')).not_to zen_empty
    class ClassesCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Returns all instance and class methods across every class in the collection.
      #
      # @return [MethodsCollection]
      def all_methods
        instance_plus_class_methods = flat_map { |klass| klass.instance_methods + klass.class_methods }
        MethodsCollection.new(instance_plus_class_methods)
      end

      # Returns all attribute declarations across every class.
      #
      # @return [AttributesCollection]
      def attributes
        all_attributes = flat_map(&:attributes)
        AttributesCollection.new(all_attributes)
      end

      # Returns all macro invocations across every class.
      #
      # @return [MacrosCollection]
      def macros
        all_macros = flat_map(&:macros)
        MacrosCollection.new(all_macros)
      end

      # Returns all rescue declarations across every class.
      #
      # @return [RescuesCollection]
      def rescues
        all_rescues = flat_map(&:rescues)
        RescuesCollection.new(all_rescues)
      end

      # Returns all raise declarations across every class.
      #
      # @return [RaisesCollection]
      def raises
        all_raises = flat_map(&:raises)
        RaisesCollection.new(all_raises)
      end

      # Filters classes whose superclass starts with the given prefix.
      #
      # @param prefix [String] the superclass name prefix to match
      # @return [ClassesCollection]
      def with_parent_prefix(prefix)
        filter { |klass| klass.superclass_prefix?(prefix) }
      end

      # Filters classes that contain at least one macro with the given name.
      #
      # @param macro_name [String] the macro name to search for
      # @return [ClassesCollection]
      def with_macro_name(macro_name)
        filter { |klass| klass.macros.with_name(macro_name).any? }
      end

      # Merges two ClassesCollections into a new ClassesCollection.
      #
      # @param other [ClassesCollection] the collection to merge
      # @return [ClassesCollection]
      def +(other)
        merged = super(other)
        self.class.new(merged)
      end
    end
  end
end
