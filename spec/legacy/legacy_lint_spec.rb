require 'rspec'
require 'rubyzen'

RSpec.describe 'Legacy files lint rules' do
  let(:project) { Rubyzen::Project.new }

  context "given a legacy file" do
    let(:legacy_file) { project.file_path('repos/legacy_repo.rb') }

    it "does not allow additions to it" do
      expect(legacy_file)
        .to have_maximum_line_count(5, "Do not add code to legacy files!")
    end
  end
end

# This lint rule solves this comment: https://github.com/perrystreetsoftware/Husband-Redis/pull/4676#discussion_r1850158329
