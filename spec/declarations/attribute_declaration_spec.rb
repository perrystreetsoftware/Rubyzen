require 'spec_helper'

RSpec.describe Rubyzen::Declarations::AttributeDeclaration do
  def attributes_from(source)
    file = parse_ruby(<<~RUBY)
      class Foo
        #{source}
      end
    RUBY
    file.classes.first.attributes
  end

  describe '#name' do
    it 'returns attr_reader for readers' do
      attrs = attributes_from('attr_reader :name')
      expect(attrs.first.name).to eq('attr_reader')
    end

    it 'returns attr_writer for writers' do
      attrs = attributes_from('attr_writer :name')
      expect(attrs.first.name).to eq('attr_writer')
    end

    it 'returns attr_accessor for accessors' do
      attrs = attributes_from('attr_accessor :name')
      expect(attrs.first.name).to eq('attr_accessor')
    end
  end

  describe '#symbols' do
    it 'returns the declared symbol names' do
      attrs = attributes_from('attr_reader :name, :email')
      expect(attrs.first.symbols).to eq(%w[name email])
    end
  end

  describe '#reader?' do
    it 'returns true for attr_reader' do
      attrs = attributes_from('attr_reader :name')
      expect(attrs.first.reader?).to be true
    end

    it 'returns true for attr_accessor' do
      attrs = attributes_from('attr_accessor :name')
      expect(attrs.first.reader?).to be true
    end

    it 'returns false for attr_writer' do
      attrs = attributes_from('attr_writer :name')
      expect(attrs.first.reader?).to be false
    end
  end

  describe '#writer?' do
    it 'returns true for attr_writer' do
      attrs = attributes_from('attr_writer :name')
      expect(attrs.first.writer?).to be true
    end

    it 'returns true for attr_accessor' do
      attrs = attributes_from('attr_accessor :name')
      expect(attrs.first.writer?).to be true
    end

    it 'returns false for attr_reader' do
      attrs = attributes_from('attr_reader :name')
      expect(attrs.first.writer?).to be false
    end
  end

  describe '#accessor?' do
    it 'returns true only for attr_accessor' do
      attrs = attributes_from('attr_accessor :name')
      expect(attrs.first.accessor?).to be true
    end

    it 'returns false for attr_reader' do
      attrs = attributes_from('attr_reader :name')
      expect(attrs.first.accessor?).to be false
    end
  end

  describe '#visibility' do
    it 'returns :public by default' do
      attrs = attributes_from('attr_reader :name')
      expect(attrs.first.visibility).to eq(:public)
    end

    it 'returns :private when after private keyword' do
      attrs = attributes_from("private\n  attr_reader :secret")
      expect(attrs.first.visibility).to eq(:private)
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      attrs = attributes_from('attr_reader :name')
      expect(attrs.first.class_name).to eq('Foo')
    end
  end

  describe '#private? / #protected? / #public?' do
    it 'returns true for public? by default' do
      attrs = attributes_from('attr_reader :name')
      expect(attrs.first.public?).to be true
      expect(attrs.first.private?).to be false
      expect(attrs.first.protected?).to be false
    end

    it 'returns true for private? after private keyword' do
      attrs = attributes_from("private\n  attr_reader :secret")
      expect(attrs.first.private?).to be true
      expect(attrs.first.public?).to be false
    end

    it 'returns true for protected? after protected keyword' do
      attrs = attributes_from("protected\n  attr_reader :internal")
      expect(attrs.first.protected?).to be true
      expect(attrs.first.public?).to be false
    end
  end
end
