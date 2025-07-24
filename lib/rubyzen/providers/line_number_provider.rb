module Rubyzen
  module Providers
    module LineNumberProvider
      def line
        node.loc.expression.line
      end
    end
  end
end
