require 'rspec'
require 'rubyzen'

RSpec.describe 'Models lint rules' do
  let(:project) { Rubyzen::Project.new }

  # This lint rule solves this comment: https://github.com/perrystreetsoftware/Husband-Redis/pull/4696#discussion_r1867261297
  context "given a file that resides in models" do
    let(:models_files) { project.files_in_path('models') }

    it "it has a corresponding spec file" do
      expect(models_files)
        .to have_corresponding_spec_files_in('unit/src/models', "All model files must have corresponding spec files")
    end
  end

  # This lint rule migrates this custom cop: https://github.com/perrystreetsoftware/Husband-Redis/blob/develop/linters/custom_cops/no_questions_in_models.rb
  context "given a class that resides in models" do
    let(:models_classes) { project.classes_in_path('models') }

    it "does not have questions in it" do
      expect(models_classes.methods.names).not_to include(end_with('?'))
    end
  end
end
