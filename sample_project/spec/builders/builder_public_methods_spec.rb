require 'rspec'
require 'rubyzen'

RSpec.describe 'Builder lint rules' do
  let(:project) { Rubyzen::Project.new }

  context "given a file that resides in builders" do
    let(:builder_classes) {
      project
        .classes_in_path("/builders/")
    }

    it "builder classes have only expected methods" do
      expect(builder_classes).to match_public_methods(
        method_names: [:build],
        optional_method_names: [:initialize]
      )
    end

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
