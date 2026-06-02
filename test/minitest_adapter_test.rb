require_relative 'test_helper'

# Tests the `require 'rubyzen/minitest'` entry-point contract: the Minitest adapter
# exposes the assertions and the core parsing API, without loading RSpec.
class MinitestAdapterTest < Minitest::Test
  def test_assertions_are_mixed_into_minitest
    assert_respond_to self, :assert_zen_empty
    assert_respond_to self, :assert_zen_true
    assert_respond_to self, :assert_zen_false
  end

  def test_core_parsing_api_is_loaded
    assert defined?(Rubyzen::Project), 'Rubyzen::Project should be available'
    assert defined?(Rubyzen::Collections::ClassesCollection),
           'Rubyzen collections should be available'
  end

  def test_rspec_is_not_loaded_on_the_minitest_path
    refute defined?(RSpec), "require 'rubyzen/minitest' must not load RSpec"
  end
end
