module Rubyzen
  module Collections
    # Collection of constant declarations found in files, classes, or modules.
    #
    # @example Filtering constants by name
    #   project.files.constants.with_name('VERSION')
    class ConstantsCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider
    end
  end
end
