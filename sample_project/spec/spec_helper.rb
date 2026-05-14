# frozen_string_literal: true

require 'rubyzen'

sample_src = File.expand_path('../src', __dir__)

RSpec.configure do |config|
  RSpec.shared_context 'project_config' do
    let(:project) { Rubyzen::Project.new([sample_src]) }
    let(:files) { project.files.with_paths('src/') }
    let(:all_classes) { files.classes }
    let(:all_modules) { files.modules }
    let(:controllers) { project.files.with_paths('src/controllers/').classes }
    let(:presenters) { project.files.with_paths('src/presenters/').classes }
    let(:actions) { project.files.with_paths('src/actions/').classes }
    let(:services) { project.files.with_paths('src/services/').classes }
    let(:jobs) { project.files.with_paths('src/jobs/').classes }
    let(:requests) { project.files.with_paths('src/requests/').classes }

    let(:models_files) { project.files.with_paths('src/models/') }
    let(:models) { models_files.classes }
    let(:repos) { project.files.with_paths('src/repos/').without_paths('/spec/').classes }
    let(:test_files) { project.files.with_paths('spec/') }
    let(:controller_test_files) { test_files.with_paths('/controllers/') }
  end

  config.include_context 'project_config'
end
