module Rubyzen
  module Collections
    # Base collection class for all Rubyzen collections.
    # Extends Array and replaces +select+/+reject+ with a single +filter+ method
    # that preserves the collection subclass type.
    #
    # @example Filtering a collection with a block
    #   controllers.filter { |c| c.name.end_with?('Controller') }
    class BaseCollection < Array
      undef_method(:select)
      undef_method(:reject)

      # Filters elements by the given block, returning a new collection of the same type.
      #
      # @yield [element] block that returns truthy to keep the element
      # @return [BaseCollection] a new collection containing only matching elements
      # @return [Enumerator] if no block is given
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
