module Rubyzen
  module Providers
    module MethodVisibilityProvider
      def visibility
        @visibility ||= determine_visibility
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