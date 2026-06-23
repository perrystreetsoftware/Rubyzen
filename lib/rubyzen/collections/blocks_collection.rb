module Rubyzen
  module Collections
    # Collection of block declarations (do...end / { }) found in files or methods.
    #
    # @example Finding blocks passed to a specific method
    #   project.files.blocks.with_method_name('describe')
    class BlocksCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Filters blocks by the method name they are passed to.
      #
      # @param method_name [String] the method name to match
      # @return [BlocksCollection]
      def with_method_name(method_name)
        filter { |block| block.method_name == method_name }
      end

      # Returns all call sites found inside every block.
      #
      # @return [CallSiteCollection]
      def call_sites
        all_call_sites = flat_map(&:call_sites)
        CallSiteCollection.new(all_call_sites)
      end

      # Returns all return points across every block.
      #
      # @return [ReturnsCollection]
      def returns
        ReturnsCollection.new(flat_map(&:returns))
      end

      # Returns all return expressions across every block.
      #
      # @return [ExpressionsCollection]
      def return_expressions
        returns.expressions
      end

      # Returns all local-variable assignments across every block.
      #
      # @return [AssignmentsCollection]
      def assignments
        AssignmentsCollection.new(flat_map(&:assignments))
      end
    end
  end
end
