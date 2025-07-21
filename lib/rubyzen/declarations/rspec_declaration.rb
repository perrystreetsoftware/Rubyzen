require_relative '../providers/if_statements_provider'

module Rubyzen
  module Declarations
    class RspecDeclaration
      include Providers::IfStatementsProvider

      attr_reader :node, :file_declaration

      def initialize(node, file_declaration)
        @node = node
        @file_declaration = file_declaration
      end

      def file_path
        file_declaration.path
      end

      def name
        main_describe_block_description
      end

      def source
        node.source
      end

      private

      def rspec_describe_node?(node)
        node.method_name == :describe && node.receiver.nil?
      end

      def main_describe_block_description
        main_describe = node.each_node(:send).find { |n| rspec_describe_node?(n) }
        if main_describe && main_describe.arguments.first&.type == :str
          main_describe.arguments.first.value
        else
          'RSpec File'
        end
      end
    end
  end
end
