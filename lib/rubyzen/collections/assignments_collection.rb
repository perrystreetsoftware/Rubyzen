module Rubyzen
  module Collections
    # Collection of {Rubyzen::Declarations::AssignmentDeclaration} (local-variable assignments).
    #
    # @example
    #   method.assignments.with_name('user')
    class AssignmentsCollection < BaseCollection
      include Rubyzen::Providers::CollectionFilterProvider
    end
  end
end
