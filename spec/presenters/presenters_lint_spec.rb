require 'rspec'
require 'rubyzen'

RSpec.describe 'Presenter lint rules' do
  let(:project) { Rubyzen::Project.new }
  let(:presenters) { project.classes_with_name_ending_with("Presenter") }

  context "given a presenter" do
    it "does not directly access repositories" do
      expect(presenters).not_to depend_on_classes_ending_with("Repository")
    end
  end
end
