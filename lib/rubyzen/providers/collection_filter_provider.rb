module Rubyzen
  module Providers
    # Provides name-based filtering methods for collections.
    module CollectionFilterProvider
      # @param name [String] the exact name to match
      # @return [self] filtered collection containing only items with the given name
      def with_name(name)
        filter { |item| item.name == name }
      end

      # @param suffix [String] the suffix to match against item names
      # @return [self] filtered collection of items whose names end with the suffix
      def with_name_ending_with(suffix)
        filter { |item| item.name&.end_with?(suffix) }
      end

      # @param prefix [String] the prefix to match against item names
      # @return [self] filtered collection of items whose names start with the prefix
      def with_name_starting_with(prefix)
        filter { |item| item.name&.start_with?(prefix) }
      end

      # @param substring [String] the substring to search for in item names
      # @param case_sensitive [Boolean] whether the match is case-sensitive (default: true)
      # @return [self] filtered collection of items whose names contain the substring
      def with_name_including(substring, case_sensitive: true)
        if case_sensitive
          filter { |item| item.name&.include?(substring) }
        else
          filter { |item| item.name&.downcase&.include?(substring.downcase) }
        end
      end

      # @param names [Array<String>] names to exclude
      # @return [self] filtered collection excluding items with any of the given names
      def without_name(*names)
        filter { |item| !names.include?(item.name) }
      end

      # @param suffix [String] the suffix to exclude
      # @return [self] filtered collection excluding items whose names end with the suffix
      def without_name_ending_with(suffix)
        filter { |item| !item.name&.end_with?(suffix) }
      end

      # @param prefix [String] the prefix to exclude
      # @return [self] filtered collection excluding items whose names start with the prefix
      def without_name_starting_with(prefix)
        filter { |item| !item.name&.start_with?(prefix) }
      end

      # @param substring [String] the substring to exclude
      # @param case_sensitive [Boolean] whether the match is case-sensitive (default: true)
      # @return [self] filtered collection excluding items whose names contain the substring
      def without_name_including(substring, case_sensitive: true)
        if case_sensitive
          filter { |item| !item.name&.include?(substring) }
        else
          filter { |item| !item.name&.downcase&.include?(substring.downcase) }
        end
      end
    end
  end
end
