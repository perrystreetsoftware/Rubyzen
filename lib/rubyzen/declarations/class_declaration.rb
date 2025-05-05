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
        super_class&.name
      end

      def superclass_name_with_modules
        super_class&.name_with_modules
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

      def full_const_name(node)
        case node.type
        when :const
          namespace_node, name = node.children
          if namespace_node
            [ full_const_name(namespace_node), name.to_s ].join("::")
          else
            name.to_s
          end
        when :cbase
          ""            # handles leading :: if you need it
        else
          nil           # not a constant
        end
      end

    end
  end
end
