require_relative 'method_declaration'
require_relative '../providers/if_statements_provider'
require_relative '../providers/blocks_provider'

module Rubyzen
  module Declarations
    class ClassDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
      attr_reader :node, :file_declaration

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

      def superclass_name
        super_node = node.children[1]
        return nil unless super_node&.type == :const
        super_node.const_name
      end

      def methods
        node.each_node(:def).map do |def_node|
          MethodDeclaration.new(def_node, self)
        end
      end

      def class_methods
        class_method_declarations = []

        # Pattern 1: def self.method_name
        node.each_node(:defs) do |defs_node|
          if defs_node.receiver&.type == :self
            class_method_declarations << MethodDeclaration.new(defs_node, self)
          end
        end

        # Pattern 2: class << self; def method_name; end; end
        node.each_node(:sclass) do |sclass_node|
          if sclass_node.receiver&.type == :self
            sclass_node.each_node(:def).each do |def_node|
              class_method_declarations << MethodDeclaration.new(def_node, self)
            end
          end
        end

        class_method_declarations
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
