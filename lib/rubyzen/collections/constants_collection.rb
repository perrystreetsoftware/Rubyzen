require_relative 'base_collection'
require_relative '../providers/collection_filter_provider'

module Rubyzen
  module Collections
    class ConstantsCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider
    end
  end
end
