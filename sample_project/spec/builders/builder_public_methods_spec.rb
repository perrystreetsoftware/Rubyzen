require 'rspec'
require 'rubyzen'

RSpec.describe 'Builder lint rules' do
  let(:project) { Rubyzen::Project.new }

  context "given a file that resides in builders" do
    let(:builder_classes) {
      project
        .classes_in_path("/builders/")
    }

    # TODO: BRING THIS BACK AND ALSO ADD OPTION FOR OPTIONAL METHODS LIKE INITIALIZE
    # it "builder classes have only expected methods" do
    #   expect(builder_classes).to match_public_methods(
    #     method_names: [:initialize, :build]
    #   )
    # end

    # it "builder classes include public build method" do
    #   expect(builder_classes).to include_public_methods(
    #     method_names: [:initialize, :build]
    #     )
    # end

    it "builder classes have public method 'initialize' with any args" do
      expect(builder_classes).to(have_method_signature(
        method: :initialize,
        signature: :any,
        visibility: :public
      ))
    end

    it "builder classes have public method 'build' with no args" do
      expect(builder_classes).to(have_method_signature(
        method: :build,
        signature: '',
        visibility: :public
      ))
    end
  end
end
