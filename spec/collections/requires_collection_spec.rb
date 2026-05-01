require 'spec_helper'

RSpec.describe Rubyzen::Collections::RequiresCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      require 'json'
      require_relative 'helper'
      load 'config.rb'
    RUBY
  end

  let(:requires) { file.requires }

  describe '#require_calls' do
    it 'filters to require statements' do
      result = requires.require_calls
      expect(result.size).to eq(1)
      expect(result.first.required_path).to eq('json')
    end
  end

  describe '#require_relative_calls' do
    it 'filters to require_relative statements' do
      result = requires.require_relative_calls
      expect(result.size).to eq(1)
      expect(result.first.required_path).to eq('helper')
    end
  end

  describe '#load_calls' do
    it 'filters to load statements' do
      result = requires.load_calls
      expect(result.size).to eq(1)
      expect(result.first.required_path).to eq('config.rb')
    end
  end

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = requires.with_name('require')
      expect(result.size).to eq(1)
    end
  end
end
