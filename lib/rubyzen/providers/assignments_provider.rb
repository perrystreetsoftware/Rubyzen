module Rubyzen
  module Providers
    # Provides local-variable assignments within a method or block.
    module AssignmentsProvider
      # @return [Rubyzen::Collections::AssignmentsCollection]
      def assignments
        Collections::AssignmentsCollection.new(
          node.each_descendant(:lvasgn).map do |assignment_node|
            Declarations::AssignmentDeclaration.new(assignment_node, self)
          end
        )
      end
    end
  end
end
