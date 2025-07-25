require_relative '../providers/if_statements_provider'
require_relative '../providers/blocks_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/constants_provider'
require_relative '../providers/call_site_provider'
require_relative '../providers/lines_of_code_provider'
require_relative '../providers/method_visibility_provider'

module Rubyzen
  module Declarations
    class MethodDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ConstantsProvider
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::CallSiteProvider
      include Rubyzen::Providers::LinesOfCodeProvider
      include Rubyzen::Providers::MethodVisibilityProvider

      attr_reader :node, :parent_class
      alias :parent :parent_class

      def initialize(node, parent_class)
        @node = node
        @parent_class = parent_class
      end

      def name
        node.method_name.to_s
      end

      def visibility
        determine_visibility
      end

      def private?
        visibility == :private
      end

      def protected?
        visibility == :protected
      end

      def public?
        visibility == :public
      end


      private

      def determine_visibility
        return :public unless parent_class

        # Find all visibility modifier nodes in the parent class
        visibility_nodes = parent_class.node.each_descendant(:send).select do |send_node|
          send_node.method_name.to_s.match?(/^(private|protected|public)$/) &&
          send_node.arguments.empty? # No arguments means it affects following methods
        end

        # Find the last visibility modifier that appears before this method
        method_line = node.loc.expression.line
        
        applicable_visibility = visibility_nodes
          .select { |v_node| v_node.loc.expression.line < method_line }
          .max_by { |v_node| v_node.loc.expression.line }

        if applicable_visibility
          applicable_visibility.method_name.to_sym
        else
          :public # Default visibility in Ruby
        end
      end
    end
  end
end
