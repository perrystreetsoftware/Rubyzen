require 'digest'

module Rubyzen
  # Caching utilities for parsed AST results.
  module Cache
    # In-memory cache for parsed AST results, keyed by file path and SHA256 checksum.
    # Automatically invalidates entries when file contents change.
    class ParseCache
      def initialize
        @cache = {}
      end

      # Returns the cached result for the given file, or yields to parse and cache it.
      #
      # @param file_path [String] absolute path to the file
      # @yield block that parses the file and returns the result to cache
      # @return [Object] the cached or freshly parsed result
      def fetch_or_parse(file_path, &block)
        checksum = file_checksum(file_path)

        if @cache.key?(file_path) && @cache[file_path][:checksum] == checksum
          @cache[file_path][:result]
        else
          result = block.call
          @cache[file_path] = { checksum: checksum, result: result }
          result
        end
      end

      private

      def file_checksum(file_path)
        Digest::SHA256.file(file_path).hexdigest
      end
    end
  end
end
