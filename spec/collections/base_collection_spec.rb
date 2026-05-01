require 'spec_helper'

RSpec.describe Rubyzen::Collections::BaseCollection do
  describe '#filter' do
    it 'returns the same collection type' do
      collection = Rubyzen::Collections::ClassesCollection.new
      result = collection.filter { true }
      expect(result).to be_a(Rubyzen::Collections::ClassesCollection)
    end

    it 'filters elements by the block condition' do
      file = parse_ruby(<<~RUBY)
        class Foo; end
        class Bar; end
      RUBY

      classes = Rubyzen::Collections::ClassesCollection.new(file.classes)
      result = classes.filter { |c| c.name == 'Foo' }
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('Foo')
    end

    it 'returns an enumerator when no block is given' do
      collection = Rubyzen::Collections::ClassesCollection.new
      expect(collection.filter).to be_a(Enumerator)
    end
  end

  describe 'select and reject are undefined' do
    it 'raises NoMethodError for select' do
      collection = Rubyzen::Collections::BaseCollection.new
      expect { collection.select }.to raise_error(NoMethodError)
    end

    it 'raises NoMethodError for reject' do
      collection = Rubyzen::Collections::BaseCollection.new
      expect { collection.reject }.to raise_error(NoMethodError)
    end
  end
end
