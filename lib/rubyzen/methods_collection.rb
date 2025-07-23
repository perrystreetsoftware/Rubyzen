module Rubyzen
  class MethodsCollection < Array
    def initialize(method_declarations)
      super(method_declarations)
    end

    def names
      map(&:name)
    end

    def if_statements
      flat_map do |method|
        method.if_statements
      end
    end
  end
end
