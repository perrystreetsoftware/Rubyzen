require 'rspec'
require 'rubyzen'

RSpec.describe 'Actions lint rules' do
  let(:project) { Rubyzen::Project.new }

  context "given a file that resides in actions" do
    let(:action_classes) {
      project
        .classes_in_path("/actions/")
    }

    # it "builder classes have only expected methods" do
    #   expect(action_classes).to match_public_methods(
    #     method_names: [:initialize, :build]
    #   )
    # end

    # it "builder classes include public build method" do
    #   expect(action_classes).to include_public_methods(
    #     method_names: [:initialize, :build]
    #     )
    # end

    # it "action classes have public method 'initialize' with any args" do
    #   expect(action_classes).to(have_method_signature(
    #     method: :initialize,
    #     signature: :any,
    #     visibility: :public
    #   ))
    # end

    it "action classes have public method 'execute' with any args" do
      expect(action_classes).to(have_method_signature(
        method: :execute,
        signature: :any,
        visibility: :public
      ))
    end
  end
end
