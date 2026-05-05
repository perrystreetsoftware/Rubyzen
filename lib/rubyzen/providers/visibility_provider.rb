module Rubyzen
  module Providers
    # Provides method visibility detection (public, private, protected).
    module VisibilityProvider
      # @return [Symbol] the visibility of this declaration (:public, :private, or :protected)
      def visibility
        determine_visibility
      end

      # @return [Boolean] true if this declaration is private
      def private?
        visibility == :private
      end

      # @return [Boolean] true if this declaration is protected
      def protected?
        visibility == :protected
      end

      # @return [Boolean] true if this declaration is public
      def public?
        visibility == :public
      end

      private

      def determine_visibility
        return :public unless parent_class

        visibility_nodes = parent_class.node.each_descendant(:send).select do |send_node|
          send_node.method_name.to_s.match?(/^(private|protected|public)$/) &&
          send_node.arguments.empty?
        end

        declaration_line = node.loc.expression.line

        applicable_visibility = visibility_nodes
          .select { |v_node| v_node.loc.expression.line < declaration_line }
          .max_by { |v_node| v_node.loc.expression.line }

        if applicable_visibility
          applicable_visibility.method_name.to_sym
        else
          :public
        end
      end
    end
  end
end
