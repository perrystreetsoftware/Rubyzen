require 'rspec'
require 'rubyzen'

RSpec.describe 'Database lint rules' do
  let(:project) { Rubyzen::Project.new }
  let(:non_repo_classes) { project.classes_without_path("repos") }

  context "given a class that is not a repo" do
    it "does not call the where method" do
      expect(non_repo_classes)
        .not_to(call_method(:where, "Do not query the database outside of repositories"))
    end
  end
end

# This lint rule solves this comment: https://github.com/perrystreetsoftware/Husband-Redis/pull/4706#discussion_r1870962075
# It also replaces this custom cop https://github.com/perrystreetsoftware/Husband-Redis/blob/develop/linters/custom_cops/model_use_outside_of_repo.rb
