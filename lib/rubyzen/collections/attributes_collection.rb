require_relative 'base_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    # Collection of attribute declarations (attr_reader, attr_writer, attr_accessor).
    #
    # @example Ensuring no class uses attr_accessor
    #   expect(controllers.attributes.accessors).to be_empty
    class AttributesCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      # Returns only +attr_reader+ attributes.
      #
      # @return [AttributesCollection]
      def readers
        filter(&:reader?)
      end

      # Returns only +attr_writer+ attributes.
      #
      # @return [AttributesCollection]
      def writers
        filter(&:writer?)
      end

      # Returns only +attr_accessor+ attributes.
      #
      # @return [AttributesCollection]
      def accessors
        filter(&:accessor?)
      end
    end
  end
end
