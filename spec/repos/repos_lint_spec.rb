require 'rspec'
require 'rubyzen'

RSpec.describe 'Repositories lint rules' do
  let(:project) { Rubyzen::Project.new }
  let(:repos) { project.classes_in_path("repos") }

  context "given a repository" do
    it "is within a Repos module" do
      expect(repos).to have_top_level_module("Repos")
    end
  end
end
