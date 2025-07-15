require 'rspec'
require 'rubyzen'

RSpec.describe 'No blocks in models' do
  let(:project) { Rubyzen::Project.new }

  context "given a class that resides in models" do
    let(:models_classes) { project.classes_in_path('models') }

    it "has no blocks" do
      expect(models_classes).not_to have_blocks("No blocks allowed in model classes")
    end
  end
end
