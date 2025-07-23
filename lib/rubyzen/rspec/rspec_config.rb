
module RSpec
  module Matchers
    alias_method :__original_expect, :expect

    # override the public `expect` entrypoint
    def expect(actual = nil, &block)
      unless valid_collection_subject?(actual)
        binding.pry
        raise ArgumentError,
              "Invalid subject for `expect`: " \
              "only Rubyzen::Domain::Collection or Array of them allowed, " \
              "but got #{actual.inspect}"
      end

      __original_expect(actual, &block)
    end

    private

    def in_collections_namespace?(obj)
      obj.class.to_s.start_with?("#{Rubyzen::Collections.name}::")
    end

    def valid_collection_subject?(subject)
      in_collections_namespace?(subject)
    end
  end
end
