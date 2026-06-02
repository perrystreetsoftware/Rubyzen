require_relative '../test_helper'

# Minitest equivalent of spec/controllers/no_if_statements_in_controllers_lint_spec.rb.
class NoIfStatementsInControllersTest < LintTestCase
  def baseline
    []
  end

  def target_classes
    (controllers + presenters).without_name(*baseline)
  end

  def test_has_no_if_statements_in_methods
    assert_zen_empty(target_classes.all_methods.if_statements)
  end

  def test_has_no_if_statements_in_methods_using_true_with_a_block
    assert_zen_true(target_classes.all_methods) { |m| m.if_statements.count.zero? }
  end

  def test_has_no_if_statements_in_methods_using_false_with_a_block
    assert_zen_false(target_classes.all_methods) { |m| !m.if_statements.count.zero? }
  end
end
