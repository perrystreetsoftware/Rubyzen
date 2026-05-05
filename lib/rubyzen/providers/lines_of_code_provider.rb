module Rubyzen
  module Providers
    # Provides the number of lines of code a declaration spans.
    module LinesOfCodeProvider
      # @return [Integer] the total number of source lines in this declaration
      def lines_of_code
        node.loc.expression.source.split("\n").size
      end
    end
  end
end
