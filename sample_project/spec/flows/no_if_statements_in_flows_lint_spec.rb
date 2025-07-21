require 'rspec'
require 'rubyzen'

RSpec.describe 'No if statements in flows' do
  let(:project) { Rubyzen::Project.new }
  let(:flow_spec_declarations) { project.rspec_declarations_for_files_ending_with('_flow_spec.rb') }

  let(:non_allowlisted_flow_specs) do
    flow_spec_declarations.reject do |flow_spec|
      file_path_without_prefix = flow_spec.file_path.to_s.sub(/^\.\/target_project\//, '')
      FLOW_SPEC_IF_STATEMENTS_ALLOWLIST.include?(file_path_without_prefix)
    end
  end

  context "given flow spec files" do
    it "has no if statements" do

      expect(non_allowlisted_flow_specs).not_to have_if_statements
    end
  end
end

FLOW_SPEC_IF_STATEMENTS_ALLOWLIST = [
  'spec/unit/src/api/admin/event_flow_spec.rb',
  'spec/unit/src/api/app/albums/creating_albums_flow_spec.rb',
  'spec/unit/src/api/app/alerts/promotions_flow_spec.rb',
  'spec/unit/src/api/app/boosts/boost_attribution_flow_spec.rb',
  'spec/unit/src/api/app/chat/chat_album_uploads_flow_spec.rb',
  'spec/unit/src/api/app/chat/read_receipt_pro_user_flow_spec.rb',
  'spec/unit/src/api/app/visitors/indicators_flow_spec.rb'
].freeze
