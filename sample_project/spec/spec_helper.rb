require 'rubyzen'
require 'pry'

RSpec.configure do |config|
	RSpec.shared_context 'project_config' do
		let(:project) { Rubyzen::Project.new }
		let(:all_classes) { project.classes.with_path_include('src/') }
		let(:controllers) { project.classes.with_path_include('src/controllers/') }
		let(:presenters) { project.classes.with_path_include('src/presenters/') }
		let(:services) { project.classes.with_path_include('src/services/') }

		let(:models) { project.classes.with_path_include('src/models/') }
		let(:test_files) { project.files.files_in_path('spec/') }
		let(:controller_tests) { test_files.files_in_path('/controllers/') }
	end

	config.include_context 'project_config'
end
