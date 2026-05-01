module Rubyzen
  module Collections
    # Collection of method parameter declarations.
    #
    # @example Filtering parameters by name
    #   controllers.all_methods.parameters.with_name('id')
    class ParametersCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider
    end
  end
end
