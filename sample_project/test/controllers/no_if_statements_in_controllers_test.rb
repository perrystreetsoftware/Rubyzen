require_relative '../test_helper'

# Minitest equivalent of spec/controllers/no_if_statements_in_controllers_lint_spec.rb.
class NoIfStatementsInControllersTest < LintTestCase
  RULE = Rubyzen::Rule.new do
    description 'Controllers and presenters do not contain if statements.'
    rationale <<~TEXT
      Controllers only orchestrate a request and presenters only format a response.
      Branching in them hides business logic where it cannot be reused or unit-tested.
    TEXT
    fix_hint 'Move the condition into a Service (or a Question) and call it from the controller.'
    bad_example <<~RUBY
      def index
        if rand > 0.5
          render_success
        end
      end
    RUBY
    good_example <<~RUBY
      def index
        Services::Index.new.call
      end
    RUBY
  end

  def baseline
    []
  end

  def target_classes
    (controllers + presenters).without_name(*baseline)
  end

  def test_has_no_if_statements_in_methods
    assert_zen_empty(target_classes.all_methods.if_statements, rule: RULE)
  end

  def test_has_no_if_statements_in_methods_using_true_with_a_block
    assert_zen_true(target_classes.all_methods, rule: RULE) { |m| m.if_statements.count.zero? }
  end

  def test_has_no_if_statements_in_methods_using_false_with_a_block
    assert_zen_false(target_classes.all_methods, rule: RULE) { |m| !m.if_statements.count.zero? }
  end
end
