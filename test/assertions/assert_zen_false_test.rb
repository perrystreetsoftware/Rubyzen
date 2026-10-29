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

  def rule
    Rubyzen::Rule.new(description: 'Only FooController is allowed.', fix_hint: 'Rename it to FooController.')
  end

  def test_zen_false_shows_the_rule_followed_by_the_violations
    error = assert_raises(Minitest::Assertion) do
      assert_zen_false(two_controllers, rule: rule) { |c| c.name == 'BarController' }
    end
    assert_equal(<<~MESSAGE.chomp, error.message)
      RULE: Only FooController is allowed.

      HOW TO FIX: Rename it to FooController.

      Violations:
        - element: BarController
        - class: BarController
        - file: /app/controllers/foo_controller.rb:2
    MESSAGE
  end

  def test_zen_false_supports_a_rule_with_a_baseline
    assert_zen_false(two_controllers, rule: rule, baseline: %w[BarController]) { |c| c.name == 'BarController' }
  end

  def test_zen_false_prefers_a_custom_message_over_the_rule
    error = assert_raises(Minitest::Assertion) do
      assert_zen_false(two_controllers, message: 'Custom message', rule: rule) { |c| c.name == 'BarController' }
    end
    assert_match(/\ACustom message\n/, error.message)
  end
end
