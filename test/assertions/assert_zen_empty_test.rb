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
end
