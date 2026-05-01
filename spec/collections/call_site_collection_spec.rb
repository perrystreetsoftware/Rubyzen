require 'spec_helper'

RSpec.describe Rubyzen::Collections::CallSiteCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        def bar
          User.find(1)
          logger.info(:debug, details: "msg")
          save
        end
      end
    RUBY
  end

  let(:call_sites) { file.classes.first.instance_methods.first.call_sites }

  describe '#with_receiver' do
    it 'filters by receiver constant' do
      result = call_sites.with_receiver('User')
      expect(result.size).to eq(1)
      expect(result.first.method_name).to eq('find')
    end
  end

  describe '#with_name / #with_method_name' do
    it 'filters by method name' do
      result = call_sites.with_name('save')
      expect(result.size).to eq(1)
    end

    it 'with_method_name is an alias' do
      result = call_sites.with_method_name('save')
      expect(result.size).to eq(1)
    end
  end

  describe '#with_symbol' do
    it 'filters by symbol argument' do
      result = call_sites.with_symbol(:debug)
      expect(result.size).to eq(1)
      expect(result.first.method_name).to eq('info')
    end
  end

  describe '#with_keyword_arg' do
    it 'filters by keyword argument key' do
      result = call_sites.with_keyword_arg(:details)
      expect(result.size).to eq(1)
      expect(result.first.method_name).to eq('info')
    end
  end

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = call_sites.with_name('find')
      expect(result.size).to eq(1)
    end
  end
end
