require_relative 'method_declaration'
require_relative '../providers/if_statements_provider'
require_relative '../providers/blocks_provider'

module Rubyzen
  module Declarations
    class ClassDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
      attr_reader :node, :file_declaration

      attr_accessor :super_class

      def initialize(node, file_declaration)
        @node = node
        @file_declaration = file_declaration
      end

      def file_path
        file_declaration.path
      end

      def name
        node.identifier&.const_name
      end

      def name_with_modules
        [file_declaration.modules.map(&:name), name].flatten.compact.join('::')
      end

      def subclasses
        @subclasses ||= []
      end

      def superclass_name
        super_node = node.children[1]
        return nil unless super_node&.type == :const
        super_node.const_name
      end

      def superclass_name_with_modules
        super_node = node.children[1]
        return nil unless super_node&.type == :const

        # If it's a fully qualified constant path (e.g., ::Module::Class)
        if super_node.type == :const && super_node.namespace&.type == :cbase
          return super_node.const_name
        end

        # If it's a relative constant path with explicit modules (e.g., Module::Class)
        if super_node.type == :const && super_node.namespace&.type == :const
          return super_node.const_name
        end

        # If it's just a class name without modules, use the current class's modules
        modules_prefix = file_declaration.modules.map(&:name).compact.join('::')
        superclass = superclass_name
        return nil unless superclass

        modules_prefix.empty? ? superclass : "#{modules_prefix}::#{superclass}"
      end

      def methods(visibility = nil)
        node.each_node(:def).map do |def_node|
          MethodDeclaration.new(def_node, self)
        end.select do |method_decl|
          case visibility
          when :public
            method_decl.public_method?
          when :private
            !method_decl.public_method?
          when nil
            true
          else
            raise ArgumentError, "Invalid visibility: #{visibility}. Use :public, :private, or nil."
          end
        end
      end

      def methods_including_inherited(visibility = nil)
        all_methods = methods(visibility)

        return all_methods if super_class.nil?

        all_methods += super_class.methods_including_inherited(visibility)
        all_methods.uniq { |m| m.name }
      end

      def called_method_names
        node.each_descendant(:send).map { |send_node| send_node.method_name.to_s }.uniq
      end

      def constants_referenced
        node.each_descendant(:const).map(&:const_name).uniq
      end

      def top_level_module
        file_declaration.top_level_module_name
      end

      def call_sites
        node.each_descendant(:send).map do |send_node|
          {
            receiver: send_node.receiver&.type == :const ? send_node.receiver.const_name : nil,
            method_name: send_node.method_name.to_s,
            keyword_args: extract_keyword_args(send_node),
            line: send_node.loc.expression.line
          }
        end
      end

      private

      def extract_keyword_args(send_node)
        send_node.arguments.flat_map do |arg|
          if arg.hash_type?
            arg.each_pair.map do |pair|
              key_node = pair.key
              key_node.type == :sym ? key_node.value : nil
            end.compact
          else
            []
          end
        end.uniq
      end
    end
  end
end
