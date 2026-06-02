require_relative '../test_helper'

# Minitest equivalent of spec/models/no_arguments_named_biz_spec.rb.
class NoArgumentsNamedBizTest < LintTestCase
  def test_has_no_method_arguments_named_biz
    assert_zen_false(models.all_methods.parameters) { |param| param.name == :biz }
  end
end
