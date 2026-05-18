module Rubyzen
  # Domain objects wrapping AST nodes with high-level accessors.
  module Declarations
    # Represents a parsed Ruby source file. This is the root of the declaration
    # hierarchy — all other declarations are accessed through a FileDeclaration.
    #
    # @example
    #   project = Rubyzen::Project.new("/app/src")
    #   file = project.files.first
    #   file.name      #=> "user.rb"
    #   file.classes   #=> [ClassDeclaration, ...]
    #
    class FileDeclaration
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::ConstantsProvider
      include Rubyzen::Providers::RequiresProvider
      include Rubyzen::Providers::CallSiteProvider
      include Rubyzen::Providers::BlocksProvider

      # @return [String] absolute path to the source file
      attr_reader :path

      # @return [RuboCop::AST::Node] the root AST node
      attr_reader :node
      alias :ast :node

      # @param path [String] absolute file path
      # @param ast [RuboCop::AST::Node] parsed AST root node
      def initialize(path, ast)
        @path = path
        @node = ast
      end

      # Returns the basename of the file.
      #
      # @return [String] e.g. +"user.rb"+
      def name
        File.basename(path)
      end

      # Returns all classes defined in this file.
      #
      # @return [Array<ClassDeclaration>]
      def classes
        node.each_node(:class).map do |class_node|
          ClassDeclaration.new(class_node, self)
        end
      end

      # Returns the name of the first module in the file, used to determine
      # the top-level namespace.
      #
      # @return [String, nil]
      def top_level_module_name
        modules.first&.name_without_modules
      end

      # Returns all modules defined in this file.
      #
      # @return [Array<ModuleDeclaration>]
      def modules
        node.each_node(:module).map do |module_node|
          Rubyzen::Declarations::ModuleDeclaration.new(module_node, self)
        end
      end
    end
  end
end
