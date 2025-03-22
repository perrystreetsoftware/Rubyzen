require 'digest'

module Rubyzen
  module Cache
    class ParseCache
      def initialize
        @cache = {}
      end

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
