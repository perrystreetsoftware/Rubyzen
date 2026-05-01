module Rubyzen
  module Declarations
    # Represents a Ruby class definition. Provides access to methods, attributes,
    # macros, and other class-level constructs.
    #
    # @example
    #   klass = file.classes.first
    #   klass.name                #=> "Admin::UsersController"
    #   klass.superclass_name     #=> "ApplicationController"
    #   klass.instance_methods    #=> MethodsCollection
    #
    class ClassDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::ConstantsProvider
      include Rubyzen::Providers::AttributesProvider
      include Rubyzen::Providers::MacrosProvider
      include Rubyzen::Providers::RescuesProvider
      include Rubyzen::Providers::RaisesProvider

      # @return [RuboCop::AST::Node] the class AST node
      attr_reader :node

      # @return [FileDeclaration] the file this class belongs to
      attr_reader :file_declaration

      # @param node [RuboCop::AST::Node]
      # @param file_declaration [FileDeclaration]
      def initialize(node, file_declaration)
        @node = node
        @file_declaration = file_declaration
      end

      # Returns the fully-qualified class name including parent modules.
      #
      # @return [String] e.g. +"Admin::UsersController"+
      def name
        parent_module_names = []
        current_node = node.parent

        while current_node
          if current_node.type == :module
            parent_module_names.unshift(current_node.identifier&.const_name)
          end
          current_node = current_node.parent
        end

        [parent_module_names, name_without_modules].flatten.compact.join('::')
      end

      # Returns the class name without module prefixes.
      #
      # @return [String] e.g. +"UsersController"+
      def name_without_modules
        node.identifier&.const_name
      end

      # Returns the superclass name, if any.
      #
      # @return [String, nil] e.g. +"ApplicationController"+
      def superclass_name
        super_node = node.children[1]
        return nil unless super_node&.type == :const

        super_node.const_name
      end

      # Checks whether the superclass name starts with the given prefix.
      #
      # @param prefix [String]
      # @return [Boolean]
      def superclass_prefix?(prefix)
        superclass_name&.start_with?(prefix)
      end

      # Returns instance methods defined directly in this class.
      #
      # @return [Collections::MethodsCollection]
      def instance_methods
        Collections::MethodsCollection.new(
          instance_method_nodes.map do |def_node|
            MethodDeclaration.new(def_node, self)
          end
        )
      end

      # Returns class methods (both +self.method+ and +class << self+ styles).
      #
      # @return [Collections::MethodsCollection]
      def class_methods
        Collections::MethodsCollection.new(
          class_method_nodes.map do |method_node|
            MethodDeclaration.new(method_node, self)
          end
        )
      end

      # Returns unique method names called anywhere in this class.
      #
      # @return [Array<String>]
      def called_method_names
        node.each_descendant(:send).map { |send_node| send_node.method_name.to_s }.uniq
      end

      # Returns the top-level module name from the enclosing file.
      #
      # @return [String, nil]
      def top_level_module
        file_declaration.top_level_module_name
      end

      private

      def class_body_node
        node.children[2]
      end

      def class_body_children
        body = class_body_node
        return [] unless body

        body.type == :begin ? body.child_nodes : [body]
      end

      def instance_method_nodes
        class_body_children.select { |child| child.type == :def }
      end

      def class_defs_nodes
        class_body_children.select do |child|
          child.type == :defs && child.children[0]&.type == :self
        end
      end

      def class_method_nodes
        class_defs_nodes + class_sclass_def_nodes
      end

      def class_sclass_def_nodes
        class_body_children
          .select { |child| singleton_class_node?(child) }
          .flat_map do |child|
          body_children(child.children[1]).select do |body_child|
            method_node?(body_child)
          end
        end
      end

      def singleton_class_node?(child)
        child.type == :sclass && child.children[0]&.type == :self
      end

      def body_children(body)
        return [] unless body

        body.type == :begin ? body.child_nodes : [body]
      end

      def method_node?(child)
        %i[def defs].include?(child.type)
      end
    end
  end
end
