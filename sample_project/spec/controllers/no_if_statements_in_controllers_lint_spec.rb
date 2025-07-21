require 'rspec'
require 'rubyzen'

RSpec.describe 'No if statements in controllers' do
  let(:project) { Rubyzen::Project.new }
  let(:controllers) { project.classes_with_name_ending_with("Controller") }
  let(:controller_classes) { project.classes_in_path('src/controllers') }

  let(:non_allowlisted_controllers) do
    controller_classes.reject do |controller_class|
      CONTROLLER_IF_STATEMENTS_ALLOWLIST.any? do |allowlisted_path|
        controller_class.file_path.to_s.end_with?(allowlisted_path)
      end
    end
  end

  context "given controller classes" do
    it "has no if statements in methods" do
      expect(non_allowlisted_controllers).not_to have_if_statements
    end
  end
end

CONTROLLER_IF_STATEMENTS_ALLOWLIST = [
  'src/controllers/accounts/register_factory.rb',
  'src/controllers/album_images/create.rb',
  'src/controllers/albums/cover_image.rb',
  'src/controllers/alerts/template.rb',
  'src/controllers/banners/app_index.rb',
  'src/controllers/chat/save.rb',
  'src/controllers/profile_photos/state.rb',
  'src/controllers/stores/apple_purchase_factory.rb',
  'src/controllers/tickets/list.rb',
  'src/controllers/tickets/show.rb'
].freeze
