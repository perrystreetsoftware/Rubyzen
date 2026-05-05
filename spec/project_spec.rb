require 'spec_helper'

RSpec.describe Rubyzen::Project do
  let(:fixtures_path) { File.expand_path('../fixtures', __FILE__) }

  describe '#files' do
    it 'returns a FileCollection of all .rb files' do
      project = Rubyzen::Project.new(fixtures_path)
      files = project.files
      expect(files).to be_a(Rubyzen::Collections::FileCollection)
      expect(files.size).to be >= 2
    end

    it 'supports path filtering via with_paths' do
      project = Rubyzen::Project.new(fixtures_path)
      controllers = project.files.with_paths('controllers/')
      expect(controllers.size).to eq(1)
      expect(controllers.first.name).to eq('sample_controller.rb')
    end

    it 'supports path exclusion via without_paths' do
      project = Rubyzen::Project.new(fixtures_path)
      non_controllers = project.files.without_paths('controllers/')
      expect(non_controllers.map(&:name)).not_to include('sample_controller.rb')
    end
  end

  describe '#classes' do
    it 'returns a ClassesCollection of all classes across files' do
      project = Rubyzen::Project.new(fixtures_path)
      classes = project.classes
      expect(classes).to be_a(Rubyzen::Collections::ClassesCollection)
      expect(classes.map(&:name_without_modules)).to include('SampleController', 'SampleModel')
    end
  end

  describe '#modules' do
    it 'returns a ModulesCollection of all modules across files' do
      project = Rubyzen::Project.new(fixtures_path)
      modules = project.modules
      expect(modules).to be_a(Rubyzen::Collections::ModulesCollection)
      expect(modules.map(&:name)).to include('Controllers')
    end
  end

  describe 'with multiple paths' do
    it 'accepts an array of paths' do
      controllers_path = File.join(fixtures_path, 'controllers')
      models_path = File.join(fixtures_path, 'models')
      project = Rubyzen::Project.new([controllers_path, models_path])
      expect(project.files.size).to eq(2)
    end
  end
end
