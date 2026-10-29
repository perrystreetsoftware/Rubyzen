require_relative '../test_helper'

# Minitest equivalent of spec/matchers/zen_true_matcher_spec.rb.
class AssertZenTrueTest < Minitest::Test
  include ParseHelper

  def two_controllers
    file = parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
      class FooController; end
      class BarController; end
    RUBY
    file.classes
  end

  def test_zen_true_passes_when_block_true_for_all
    assert_zen_true(two_controllers) { |c| c.name.end_with?('Controller') }
  end

  def test_zen_true_fails_when_block_false_for_some
    error = assert_raises(Minitest::Assertion) do
      assert_zen_true(two_controllers) { |c| c.name == 'FooController' }
    end
    assert_match(/Expected to return true for all elements/, error.message)
  end

  def test_zen_true_requires_a_block
    assert_raises(ArgumentError) { assert_zen_true(two_controllers) }
  end

  def test_zen_true_supports_allowlist
    assert_zen_true(two_controllers, allowlist: %w[BarController]) { |c| c.name == 'FooController' }
  end

  def test_zen_true_supports_custom_message
    error = assert_raises(Minitest::Assertion) do
      assert_zen_true(two_controllers, message: 'All must be Foo') { |c| c.name == 'FooController' }
    end
    assert_match(/All must be Foo/, error.message)
  end

  def rule
    Rubyzen::Rule.new(description: 'Only FooController is allowed.', fix_hint: 'Rename it to FooController.')
  end

  def test_zen_true_shows_the_rule_followed_by_the_violations
    error = assert_raises(Minitest::Assertion) do
      assert_zen_true(two_controllers, rule: rule) { |c| c.name == 'FooController' }
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

  def test_zen_true_supports_a_rule_with_a_baseline
    assert_zen_true(two_controllers, rule: rule, baseline: %w[BarController]) { |c| c.name == 'FooController' }
  end

  def test_zen_true_prefers_a_custom_message_over_the_rule
    error = assert_raises(Minitest::Assertion) do
      assert_zen_true(two_controllers, message: 'Custom message', rule: rule) { |c| c.name == 'FooController' }
    end
    assert_match(/\ACustom message\n/, error.message)
  end
end
