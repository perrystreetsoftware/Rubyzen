require 'rspec'
require 'rubyzen'

RSpec.describe 'Database lint rules' do
  let(:project) { Rubyzen::Project.new }
  let(:non_repo_classes) { project.classes_without_path("/repos/") } # or project.classes_without_module("Repos")
  let(:active_record_models) { 
    project
      .classes_in_path("/models/")
      .classes_inheriting_from(->(name) { name&.start_with?("ActiveRecord::BaseAurora") })
      .excluding_classes(ACTIVE_RECORD_MODEL_ALLOWLIST)
  }

  context "given a class that is not a repo" do
    it "does not call any ActiveRecord methods on ActiveRecord models" do
      expect(non_repo_classes)
        .not_to(call_method(
          ACTIVE_RECORD_METHODS,
          on_receivers: active_record_models,
          message: "Do not query the database outside of repositories"
        ))
    end
  end
end

ACTIVE_RECORD_METHODS = %w[
  :all :average :calculate :count :create :create! :delete_all :destroy_all :distinct
  :eager_load :find :find_by :find_by_sql :find_each :find_in_batches :find_or_create_by
  :find_or_create_by! :find_or_initialize_by :first :group :having :ids :includes :joins :last
  :left_outer_joins :lock :maximum :minimum :order :pick :pluck :preload :reorder :select :sum
  :update :update_all :where :first_or_create :first_or_create! :first_or_initialize
].freeze

ACTIVE_RECORD_MODEL_ALLOWLIST = %w[
  :ProfilePhoto
].freeze

# This lint rule solves this comment: https://github.com/perrystreetsoftware/Husband-Redis/pull/4706#discussion_r1870962075
# It also replaces this custom cop https://github.com/perrystreetsoftware/Husband-Redis/blob/develop/linters/custom_cops/model_use_outside_of_repo.rb
