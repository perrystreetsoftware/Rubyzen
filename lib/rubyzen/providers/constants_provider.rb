require_relative '../declarations/block_declaration'
require_relative '../declarations/class_declaration'

module Rubyzen
  module Providers
    module ConstantsProvider
      def constants_referenced
        node.each_descendant(:const).map(&:const_name).uniq
      end
    end
  end
end
