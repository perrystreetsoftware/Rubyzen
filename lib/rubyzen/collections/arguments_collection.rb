module Rubyzen
  module Collections
    # Collection of {Rubyzen::Declarations::ExpressionDeclaration} representing the arguments
    # passed at a call site.
    #
    # A specialization of {ExpressionsCollection}: arguments are value-expressions, so this
    # inherits the value-expression filters (`#hash_literals`, `#constants`) and remains a
    # drop-in `ExpressionsCollection`. It exists as a distinct type so argument-specific
    # filters (e.g. positional vs keyword) can be added later without a breaking change.
    #
    # @example
    #   call_site.arguments.first.constant_name
    class ArgumentsCollection < ExpressionsCollection
    end
  end
end
