require 'spec_helper'

RSpec.describe Rubyzen::Collections::AttributesCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        attr_reader :name
        attr_writer :email
        attr_accessor :age
      end
    RUBY
  end

  let(:attributes) { file.classes.first.attributes }

  describe '#readers' do
    it 'filters to reader attributes' do
      result = attributes.readers
      expect(result.map(&:name)).to contain_exactly('attr_reader', 'attr_accessor')
    end
  end

  describe '#writers' do
    it 'filters to writer attributes' do
      result = attributes.writers
      expect(result.map(&:name)).to contain_exactly('attr_writer', 'attr_accessor')
    end
  end

  describe '#accessors' do
    it 'filters to accessor attributes only' do
      result = attributes.accessors
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('attr_accessor')
    end
  end

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = attributes.with_name('attr_reader')
      expect(result.size).to eq(1)
    end
  end
end
