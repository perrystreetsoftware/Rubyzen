# Overrides RSpec's +expect+ method to restrict subjects to Rubyzen collection types.
# This ensures that architectural lint rules only operate on valid Rubyzen collections,
# raising an ArgumentError if an unsupported subject type is passed.
module RSpec
  module Matchers
    alias_method :__original_expect, :expect

    # override the public `expect` entrypoint
    def expect(actual = nil, &block)
      if block.nil? && !valid_collection_subject?(actual)
        raise ArgumentError,
              "Invalid subject for `expect`: " \
              "only Rubyzen::Collections types allowed, " \
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
