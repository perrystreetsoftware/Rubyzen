require 'rubyzen'
require 'pry'

RSpec.configure do |config|
	RSpec.shared_context 'project_config' do
		let(:project) { Rubyzen::Project.new }
		let(:all_classes) { project.classes }
		let(:controllers) { project.classes_with_name_ending_with("Controller") }
		let(:presenters) { project.classes_with_name_ending_with("Presenter") }
		let(:services) { project.classes_with_name_ending_with("Service") }
		let(:controller_classes) { project.classes_in_path('src/controllers') }
	end

	config.include_context 'project_config'
end
