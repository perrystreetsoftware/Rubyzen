module Rubyzen
  module Declarations
    # Represents a Ruby module definition.
    #
    # @example
    #   mod = file.modules.first
    #   mod.name           #=> "Admin::Api"
    #   mod.all_methods    #=> MethodsCollection
    #   mod.classes        #=> [ClassDeclaration, ...]
    #
    class ModuleDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::ConstantsProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::AttributesProvider

      # @return [RuboCop::AST::Node]
      attr_reader :node

      # @return [FileDeclaration]
      attr_reader :file_declaration

      # @param node [RuboCop::AST::Node] the AST node
      # @param file_declaration [FileDeclaration] the parent file declaration
      def initialize(node, file_declaration)
        @node = node
        @file_declaration = file_declaration
      end

      # Returns the fully-qualified module name including parent modules.
      #
      # @return [String] e.g. +"Admin::Api"+
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

      # Returns the module name without parent module prefixes.
      #
      # @return [String]
      def name_without_modules
        node.identifier&.const_name
      end

      # Returns nested modules within this module.
      #
      # @return [Array<ModuleDeclaration>]
      def modules
        node.each_node(:module).map { |mod_node| ModuleDeclaration.new(mod_node, file_declaration) }
      end

      # Returns classes defined within this module.
      #
      # @return [Array<ClassDeclaration>]
      def classes
        node.each_node(:class).map do |class_node|
          ClassDeclaration.new(class_node, file_declaration)
        end
      end

      # Returns methods defined directly in this module.
      #
      # @return [Collections::MethodsCollection]
      def all_methods
        Collections::MethodsCollection.new(
          direct_method_nodes.map { |method_node| MethodDeclaration.new(method_node, self) }
        )
      end

      private

      def module_body_node
        node.children[1]
      end

      def module_body_children
        body = module_body_node
        return [] unless body

        body.type == :begin ? body.child_nodes : [body]
      end

      def direct_method_nodes
        direct_nodes = module_body_children.select do |child|
          %i[def defs].include?(child.type)
        end
        singleton_nodes = module_body_children.flat_map do |child|
          next [] unless child.type == :sclass
          next [] unless child.children[0]&.type == :self

          sclass_body = child.children[1]
          next [] unless sclass_body

          sclass_children = sclass_body.type == :begin ? sclass_body.child_nodes : [sclass_body]
          sclass_children.select do |sclass_child|
            %i[def defs].include?(sclass_child.type)
          end
        end

        direct_nodes + singleton_nodes
      end
    end
  end
end
