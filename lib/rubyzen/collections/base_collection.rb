module Rubyzen
  module Collections
    class BaseCollection < Array
      undef_method(:select)
      undef_method(:reject)

      def filter
        return enum_for(:filter) unless block_given?

        result = self.class.new
        each do |elem|
          result << elem if yield(elem)
        end

        result
      end
    end
  end
end
