require 'rspec'
require 'rubyzen'

RSpec.describe 'No if statements in presenters' do
  let(:project) { Rubyzen::Project.new }
  let(:presenters) { project.classes_with_name_ending_with("Presenter") }

  context "given a presenter" do
    it "has no if statements in methods" do
      expect(presenters).not_to have_if_statements
    end
  end
end
