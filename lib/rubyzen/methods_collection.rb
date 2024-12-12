module Rubyzen
  class MethodsCollection
    def initialize(method_names)
      @method_names = method_names
    end

    def names
      @method_names
    end
  end
end
