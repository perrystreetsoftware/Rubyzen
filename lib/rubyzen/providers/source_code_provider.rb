module Rubyzen
  module Providers
    module SourceCodeProvider
      def source_code
        node.loc.expression.source
      end
    end
  end
end
