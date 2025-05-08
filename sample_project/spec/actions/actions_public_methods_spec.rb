require 'rspec'
require 'rubyzen'

RSpec.describe 'Actions lint rules' do
  let(:project) { Rubyzen::Project.new }

  context "given a file that resides in actions" do
    let(:action_classes) {
      project
        .classes_in_path("/actions/")
    }

    it "classes have only expected methods" do
      expect(action_classes).to match_public_methods(
        method_names: [:execute],
        optional_method_names: [:initialize]
      )
    end

    it "classes have public method 'execute' with no args" do
      expect(action_classes).to(have_method_signature(
        method: :execute,
        signature: '',
        visibility: :public
      ))
    end
  end
end
