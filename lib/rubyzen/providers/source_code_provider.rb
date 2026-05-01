module Rubyzen
  module Providers
    # Provides access to the raw source code text of a declaration.
    module SourceCodeProvider
      # @return [String] the source code of this declaration
      def source_code
        node.loc.expression.source
      end
    end
  end
end
