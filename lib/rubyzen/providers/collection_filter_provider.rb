module Rubyzen
  module Providers
    module CollectionFilterProvider
      def with_name(name)
        filter { |item| item.name == name }
      end

      def with_name_ending_with(suffix)
        filter { |item| item.name&.end_with?(suffix) }
      end

      def with_name_starting_with(prefix)
        filter { |item| item.name&.start_with?(prefix) }
      end

      def without_name(*names)
        filter { |item| !names.include?(item.name) }
      end

      def without_name_ending_with(suffix)
        filter { |item| !item.name&.end_with?(suffix) }
      end

      def without_name_starting_with(prefix)
        filter { |item| !item.name&.start_with?(prefix) }
      end
    end
  end
end
