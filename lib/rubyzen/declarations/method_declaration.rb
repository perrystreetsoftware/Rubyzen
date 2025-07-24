require_relative '../providers/if_statements_provider'
require_relative '../providers/blocks_provider'
require_relative '../providers/line_number_provider'
require_relative '../providers/constants_provider'
require_relative '../providers/call_site_provider'
require_relative '../providers/lines_of_code_provider'

module Rubyzen
  module Declarations
    class MethodDeclaration
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::BlocksProvider
      include Rubyzen::Providers::FilePathProvider
      include Rubyzen::Providers::ClassNameProvider
      include Rubyzen::Providers::LineNumberProvider
      include Rubyzen::Providers::ConstantsProvider
      include Rubyzen::Providers::IfStatementsProvider
      include Rubyzen::Providers::CallSiteProvider
      include Rubyzen::Providers::LinesOfCodeProvider

      attr_reader :node, :parent_class
      alias :parent :parent_class

      def initialize(node, parent_class)
        @node = node
        @parent_class = parent_class
      end

      def name
        node.method_name.to_s
      end
    end
  end
end
