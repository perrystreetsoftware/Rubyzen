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
    end
  end
end
