require 'spec_helper'
require 'tmpdir'

RSpec.describe Rubyzen::Configuration do
  around do |example|
    Rubyzen.instance_variable_set(:@configuration, nil)
    example.run
  ensure
    Rubyzen.instance_variable_set(:@configuration, nil)
  end

  describe '#project_paths' do
    it 'uses auto-discovery when no paths configured' do
      config = Rubyzen::Configuration.new
      paths = config.project_paths
      expect(paths).to be_an(Array)
      expect(paths).not_to zen_empty
    end

    it 'discovers app/, lib/, src/, spec/ from Dir.pwd' do
      config = Rubyzen::Configuration.new
      paths = config.project_paths
      lib_path = File.join(Dir.pwd, 'lib')
      spec_path = File.join(Dir.pwd, 'spec')
      expect(paths).to include(lib_path)
      expect(paths).to include(spec_path)
    end

    it 'falls back to Dir.pwd when no standard directories exist' do
      Dir.mktmpdir do |tmpdir|
        real_tmpdir = File.realpath(tmpdir)
        Dir.chdir(real_tmpdir) do
          config = Rubyzen::Configuration.new
          expect(config.project_paths).to eq([real_tmpdir])
        end
      end
    end
  end

  describe 'Rubyzen.configure' do
    it 'allows setting paths via DSL' do
      Rubyzen.configure do |config|
        config.paths = ['/tmp', '/usr']
      end
      expect(Rubyzen.configuration.project_paths).to eq(['/tmp', '/usr'])
    end

    it 'resolves relative paths against Dir.pwd' do
      Rubyzen.configure do |config|
        config.paths = ['lib', 'spec']
      end
      expected = [File.join(Dir.pwd, 'lib'), File.join(Dir.pwd, 'spec')]
      expect(Rubyzen.configuration.project_paths).to eq(expected)
    end
  end

  describe 'Rubyzen.configuration' do
    it 'returns a memoized Configuration instance' do
      config1 = Rubyzen.configuration
      config2 = Rubyzen.configuration
      expect(config1).to be(config2)
    end
  end
end
