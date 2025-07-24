module Rubyzen
  module Providers
    module LinesOfCodeProvider
      def lines_of_code
        node.loc.expression.source.split("\n").size
      end
    end
  end
end
