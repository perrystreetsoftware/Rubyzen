module Rubyzen
  module Collections
    # Collection of class-level macro invocations (e.g., +validates+, +has_many+, +before_action+).
    #
    # @example Filtering macros by name
    #   controllers.macros.with_name('before_action')
    class MacrosCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider
    end
  end
end
