require_relative '../test_helper'

# Minitest equivalent of spec/repos/repos_lint_spec.rb.
class ReposTest < LintTestCase
  def test_repositories_are_within_a_repos_module
    assert_zen_true(repos) { |repo| repo.top_level_module == 'Repos' }
  end
end
