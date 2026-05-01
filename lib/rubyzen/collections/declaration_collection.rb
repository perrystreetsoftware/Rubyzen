module Rubyzen
  module Collections
    # Generic collection for declaration objects that do not require
    # specialized filtering methods (e.g., if statements).
    #
    # @example Collecting if-statement declarations from methods
    #   project.files.classes.all_methods.if_statements
    class DeclarationCollection < BaseCollection
    end
  end
end
