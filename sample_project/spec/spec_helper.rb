require 'rubyzen'
require 'pry'

RSpec.configure do |config|
	RSpec.shared_context 'project_config' do
		let(:project) { Rubyzen::Project.new }
		let(:all_classes) { project.files.with_paths('src/').classes }
		let(:controllers) { project.files.with_paths('src/controllers/').classes }
		let(:presenters) { project.files.with_paths('src/presenters/').classes }
		let(:services) { project.files.with_paths('src/services/').classes }

		let(:models) { project.files.with_paths('src/models/').classes }
		let(:repos) { project.files.with_paths('src/repos/').without_paths('/spec/').classes }
		let(:test_files) { project.files.with_paths('spec/') }
		let(:controller_test_files) { test_files.with_paths('/controllers/') }
	end

	config.include_context 'project_config'
end
