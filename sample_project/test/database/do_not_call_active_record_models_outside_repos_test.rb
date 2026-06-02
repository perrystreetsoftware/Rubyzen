require_relative '../test_helper'

# Minitest equivalent of spec/database/do_not_call_active_record_models_outside_repos_lint_spec.rb.
class DoNotCallActiveRecordModelsOutsideReposTest < LintTestCase
  ACTIVE_RECORD_METHODS = %i[
    all average calculate count create create! delete_all destroy_all distinct
    eager_load find find_by find_by_sql find_each find_in_batches find_or_create_by
    find_or_create_by! find_or_initialize_by first group having ids includes joins last
    left_outer_joins lock maximum minimum order pick pluck preload reorder select sum
    update update_all where first_or_create first_or_create! first_or_initialize
  ].freeze

  def baseline
    []
  end

  def active_record_models
    models.with_parent_prefix('ActiveRecord::BaseAurora').without_name(baseline)
  end

  def non_repo_classes
    project.files.without_paths('/repos/', '/models/').classes
  end

  def test_does_not_call_active_record_methods_on_active_record_models
    offending_calls = non_repo_classes.all_methods.call_sites.filter do |cs|
      if ACTIVE_RECORD_METHODS.include?(cs.method_name.to_sym)
        active_record_models.map(&:name).include?(cs.receiver)
      else
        false
      end
    end

    assert_zen_empty(
      offending_calls,
      message: 'Do not call ActiveRecord methods on ActiveRecord models outside of repos.'
    )
  end
end
