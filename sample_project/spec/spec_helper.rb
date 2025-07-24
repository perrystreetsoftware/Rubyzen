require 'rubyzen'
require 'pry'

RSpec.configure do |config|
	RSpec.shared_context 'project_config' do
		let(:project) { Rubyzen::Project.new }
		let(:all_classes) {  project.files.files_in_path('src/').classes }
		let(:controllers) { project.files.files_in_path('src/controllers/').classes }
		let(:presenters) {  project.files.files_in_path('src/presenters/').classes }
		let(:services) {  project.files.files_in_path('src/services/').classes }

		let(:models) {  project.files.files_in_path('src/models/').classes }
		let(:repos) {  project.files.files_in_path('src/repos/').classes }
		let(:test_files) { project.files.files_in_path('spec/') }
		let(:controller_test_files) { test_files.files_in_path('/controllers/') }
	end

	config.include_context 'project_config'
end
