require_relative '../expectation_helpers'

module Rubyzen
  # Minitest equivalents of the +zen_empty+ / +zen_true+ / +zen_false+ RSpec
  # matchers. Mixed into +Minitest::Assertions+ by +require 'rubyzen/minitest'+,
  # so the methods are available in every +Minitest::Test+ (and spec-style block).
  #
  # All three delegate to the shared {Rubyzen::ExpectationHelpers} for
  # violation/allowlist/baseline classification and failure-message formatting.
  # The behavior is identical to the RSpec matchers ({Rubyzen::Matchers}).
  #
  # @example
  #   class ArchitectureTest < Minitest::Test
  #     def test_controllers_have_no_if_statements
  #       assert_zen_empty(controllers.all_methods.if_statements)
  #     end
  #
  #     def test_repos_live_in_module
  #       assert_zen_true(repos) { |repo| repo.top_level_module == 'Repos' }
  #     end
  #   end
  module Assertions
    include Rubyzen::ExpectationHelpers
  end
end

require_relative 'assert_zen_empty'
require_relative 'assert_zen_true'
require_relative 'assert_zen_false'
