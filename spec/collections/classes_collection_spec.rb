require 'spec_helper'

RSpec.describe Rubyzen::Collections::ClassesCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo < ApplicationController
        attr_reader :name
        validates_required :name

        def bar; end
        def baz; end

        def self.build; end
      end

      class Qux < BaseModel
        def compute; end
      end
    RUBY
  end

  let(:classes) { Rubyzen::Collections::ClassesCollection.new(file.classes) }

  describe '#all_methods' do
    it 'returns all instance and class methods' do
      methods = classes.all_methods
      expect(methods).to be_a(Rubyzen::Collections::MethodsCollection)
      expect(methods.map(&:name)).to include('bar', 'baz', 'build', 'compute')
    end
  end

  describe '#attributes' do
    it 'returns all attributes across classes' do
      attrs = classes.attributes
      expect(attrs).to be_a(Rubyzen::Collections::AttributesCollection)
      expect(attrs.first.symbols).to eq(['name'])
    end
  end

  describe '#macros' do
    it 'returns all macros across classes' do
      macros = classes.macros
      expect(macros).to be_a(Rubyzen::Collections::MacrosCollection)
      expect(macros.map(&:name)).to include('validates_required')
    end
  end

  describe '#with_parent_prefix' do
    it 'filters by superclass prefix' do
      result = classes.with_parent_prefix('Application')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('Foo')
    end
  end

  describe '#with_macro_name' do
    it 'filters classes that have a specific macro' do
      result = classes.with_macro_name('validates_required')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('Foo')
    end
  end

  describe '#+' do
    it 'returns a ClassesCollection' do
      set1 = classes.filter { |c| c.name == 'Foo' }
      set2 = classes.filter { |c| c.name == 'Qux' }
      result = set1 + set2
      expect(result).to be_a(Rubyzen::Collections::ClassesCollection)
      expect(result.size).to eq(2)
    end
  end

  describe '#rescues' do
    it 'returns rescues from all classes' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            x
          rescue StandardError
            y
          end
        end
      RUBY

      classes = Rubyzen::Collections::ClassesCollection.new(file.classes)
      expect(classes.rescues).to be_a(Rubyzen::Collections::RescuesCollection)
      expect(classes.rescues.size).to eq(1)
    end
  end

  describe '#raises' do
    it 'returns raises from all classes' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            raise "oops"
          end
        end
      RUBY

      classes = Rubyzen::Collections::ClassesCollection.new(file.classes)
      expect(classes.raises.size).to eq(1)
    end
  end

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = classes.with_name('Foo')
      expect(result.size).to eq(1)
    end

    it 'supports with_name_starting_with' do
      result = classes.with_name_starting_with('F')
      expect(result.size).to eq(1)
    end

    it 'supports with_name_including' do
      result = classes.with_name_including('oo')
      expect(result.size).to eq(1)
    end

    it 'supports case-insensitive with_name_including' do
      result = classes.with_name_including('foo', case_sensitive: false)
      expect(result.size).to eq(1)
    end

    it 'supports without_name' do
      result = classes.without_name('Foo')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('Qux')
    end

    it 'supports without_name_ending_with' do
      result = classes.without_name_ending_with('ux')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('Foo')
    end

    it 'supports without_name_starting_with' do
      result = classes.without_name_starting_with('Q')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('Foo')
    end

    it 'supports without_name_including' do
      result = classes.without_name_including('ux')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('Foo')
    end

    it 'supports case-insensitive without_name_including' do
      result = classes.without_name_including('FOO', case_sensitive: false)
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('Qux')
    end
  end
end
