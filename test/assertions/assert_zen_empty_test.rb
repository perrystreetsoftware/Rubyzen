require_relative '../test_helper'

# Minitest equivalent of spec/matchers/zen_empty_matcher_spec.rb.
class AssertZenEmptyTest < Minitest::Test
  include ParseHelper

  def empty_collection
    Rubyzen::Collections::ClassesCollection.new
  end

  def single_class_collection
    parse_ruby('class Foo; end').classes
  end

  def two_controllers
    file = parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
      class FooController; end
      class BarController; end
    RUBY
    file.classes
  end

  def test_zen_empty_passes_when_collection_is_empty
    assert_zen_empty(empty_collection)
  end

  def test_zen_empty_fails_when_collection_is_not_empty
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(single_class_collection)
    end
    assert_match(/Expected to be empty/, error.message)
  end

  def test_zen_empty_supports_custom_message
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(single_class_collection, message: 'Controllers should not have violations')
    end
    assert_match(/Controllers should not have violations/, error.message)
  end

  def test_zen_empty_passes_when_all_items_allowlisted
    assert_zen_empty(two_controllers, allowlist: %w[FooController BarController])
  end

  def test_zen_empty_fails_with_non_allowlisted_items
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(two_controllers, allowlist: %w[FooController])
    end
    assert_match(/violations/i, error.message)
  end

  def test_zen_empty_fails_on_stale_allowlist_entries
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(two_controllers, allowlist: %w[FooController BarController NonExistent])
    end
    assert_match(/stale/i, error.message)
  end

  def test_zen_empty_passes_when_all_items_in_baseline
    assert_zen_empty(two_controllers, baseline: %w[FooController BarController])
  end

  def test_zen_empty_fails_on_stale_baseline_entries
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(two_controllers, baseline: %w[FooController BarController OldClass])
    end
    assert_match(/stale/i, error.message)
  end

  def rule
    Rubyzen::Rule.new(description: 'No Foo classes.', rationale: 'Foo is deprecated.', fix_hint: 'Rename Foo to Bar.')
  end

  def test_zen_empty_shows_the_rule_followed_by_the_violations
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(single_class_collection, rule: rule)
    end
    assert_equal(<<~MESSAGE.chomp, error.message)
      RULE: No Foo classes.

      WHY: Foo is deprecated.

      HOW TO FIX: Rename Foo to Bar.

      Violations:
        - element: Foo
        - class: Foo
        - file: test.rb:1
    MESSAGE
  end

  def test_zen_empty_shows_stale_baseline_entries_after_the_rule
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(empty_collection, rule: rule, baseline: %w[OldClass])
    end
    assert_match(/No Foo classes\.\n\n.*Stale baseline entries:\n  - OldClass/m, error.message)
  end

  def test_zen_empty_accepts_the_rule_as_the_message
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(single_class_collection, message: rule)
    end
    assert_match(/\ARULE: No Foo classes\./, error.message)
  end

  def test_zen_empty_prefers_a_custom_message_over_the_rule
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(single_class_collection, message: 'Custom message', rule: rule)
    end
    assert_match(/\ACustom message\n/, error.message)
    refute_match(/RULE:/, error.message)
  end

  def test_zen_empty_does_not_reuse_the_rule_of_a_previous_assertion
    assert_zen_empty(empty_collection, rule: rule)
    error = assert_raises(Minitest::Assertion) do
      assert_zen_empty(single_class_collection)
    end
    refute_match(/RULE:/, error.message)
  end

  def test_zen_empty_rejects_a_rule_that_is_not_a_rubyzen_rule
    error = assert_raises(ArgumentError) do
      assert_zen_empty(single_class_collection, rule: 'No Foo classes.')
    end
    assert_match(/Expected rule: to be a Rubyzen::Rule, got String/, error.message)
  end
end
