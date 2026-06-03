require_relative '../test_helper'

# Minitest equivalent of spec/matchers/zen_false_matcher_spec.rb.
class AssertZenFalseTest < Minitest::Test
  include ParseHelper

  def two_controllers
    file = parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
      class FooController; end
      class BarController; end
    RUBY
    file.classes
  end

  def test_zen_false_passes_when_block_false_for_all
    assert_zen_false(two_controllers) { |c| c.name == 'BazController' }
  end

  def test_zen_false_fails_when_block_true_for_some
    error = assert_raises(Minitest::Assertion) do
      assert_zen_false(two_controllers) { |c| c.name == 'FooController' }
    end
    assert_match(/Expected to return false for all elements/, error.message)
  end

  def test_zen_false_requires_a_block
    assert_raises(ArgumentError) { assert_zen_false(two_controllers) }
  end

  def test_zen_false_supports_baseline
    assert_zen_false(two_controllers, baseline: %w[FooController]) { |c| c.name == 'FooController' }
  end
end
