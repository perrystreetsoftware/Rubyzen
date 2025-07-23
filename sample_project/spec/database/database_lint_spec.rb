require 'rspec'
require 'rubyzen'
require_relative '../spec_helper'

RSpec.describe 'Do not call ActiveRecord methods on non-repo classes' do
  let(:baseline) { [] }
  let(:active_record_models) do
    models.parent_start_with?('ActiveRecord::BaseAurora')
      .excluding_classes(baseline)
  end

  context "given a class that is not a repo" do
    # remove the active record models from these as well
    let(:non_repo_classes) { project.classes.without_path_include('/repos/', '/models/') } # or project.classes_without_module("Repos")
    # let(:non_repo_classes) { project.classes.with_path_include("user_presenter") } # or project.classes_without_module("Repos")

    it "does not call any ActiveRecord methods on ActiveRecord models" do
      expect(non_repo_classes.all_methods.call_sites.filter { |cs|
        if ACTIVE_RECORD_METHODS.include?(cs.method_name.to_sym)
          active_record_models.map(&:name).include?(cs.receiver)
        else
          false
        end
      }).to be_empty
    end
  end
end

ACTIVE_RECORD_METHODS = %i[
  all average calculate count create create! delete_all destroy_all distinct
  eager_load find find_by find_by_sql find_each find_in_batches find_or_create_by
  find_or_create_by! find_or_initialize_by first group having ids includes joins last
  left_outer_joins lock maximum minimum order pick pluck preload reorder select sum
  update update_all where first_or_create first_or_create! first_or_initialize
]

ACTIVE_RECORD_MODEL_ALLOWLIST = %w[
  :ProfilePhoto
].freeze

# This lint rule solves this comment: https://github.com/perrystreetsoftware/Husband-Redis/pull/4706#discussion_r1870962075
# It also replaces this custom cop https://github.com/perrystreetsoftware/Husband-Redis/blob/develop/linters/custom_cops/model_use_outside_of_repo.rb
