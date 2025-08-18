require_relative 'base_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    class RequiresCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider

      def require_calls
        filter(&:require?)
      end

      def require_relative_calls
        filter(&:require_relative?)
      end

      def load_calls
        filter(&:load?)
      end
    end
  end
end
