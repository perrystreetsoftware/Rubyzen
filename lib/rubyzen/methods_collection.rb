module Rubyzen
  class MethodsCollection < Array
    def initialize(method_declarations)
      super(method_declarations)
    end

    def names
      map(&:name)
    end
  end
end
