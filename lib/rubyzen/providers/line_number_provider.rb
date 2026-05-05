module Rubyzen
  module Providers
    # Provides access to the starting line number of a declaration in its source file.
    module LineNumberProvider
      # @return [Integer] the line number where this declaration begins
      def line
        node.loc.expression.line
      end
    end
  end
end
