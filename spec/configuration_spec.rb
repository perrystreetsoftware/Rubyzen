require 'spec_helper'

RSpec.describe Rubyzen::Configuration do
  around do |example|
    original = ENV['RUBYZEN_PROJECT_PATHS']
    example.run
  ensure
    if original
      ENV['RUBYZEN_PROJECT_PATHS'] = original
    else
      ENV.delete('RUBYZEN_PROJECT_PATHS')
    end
    Rubyzen.instance_variable_set(:@configuration, nil)
  end

  describe '#project_paths' do
    it 'returns parsed paths from RUBYZEN_PROJECT_PATHS' do
      ENV['RUBYZEN_PROJECT_PATHS'] = '/tmp,/usr'
      config = Rubyzen::Configuration.new
      expect(config.project_paths).to eq(['/tmp', '/usr'])
    end

    it 'strips whitespace from paths' do
      ENV['RUBYZEN_PROJECT_PATHS'] = ' /tmp , /usr '
      config = Rubyzen::Configuration.new
      expect(config.project_paths).to eq(['/tmp', '/usr'])
    end

    it 'rejects empty segments' do
      ENV['RUBYZEN_PROJECT_PATHS'] = '/tmp,,/usr'
      config = Rubyzen::Configuration.new
      expect(config.project_paths).to eq(['/tmp', '/usr'])
    end
  end

  describe 'error handling' do
    it 'raises when RUBYZEN_PROJECT_PATHS is not set' do
      ENV.delete('RUBYZEN_PROJECT_PATHS')
      expect { Rubyzen::Configuration.new }.to raise_error(RuntimeError, /RUBYZEN_PROJECT_PATHS/)
    end

    it 'raises when a path does not exist' do
      ENV['RUBYZEN_PROJECT_PATHS'] = '/nonexistent/path/abc123'
      expect { Rubyzen::Configuration.new }.to raise_error(RuntimeError, /Directory not found/)
    end
  end

  describe 'Rubyzen.configuration' do
    it 'returns a memoized Configuration instance' do
      ENV['RUBYZEN_PROJECT_PATHS'] = '/tmp'
      Rubyzen.instance_variable_set(:@configuration, nil)
      config1 = Rubyzen.configuration
      config2 = Rubyzen.configuration
      expect(config1).to be(config2)
    end
  end
end
