require 'spec_helper'

RSpec.describe Rubyzen::Collections::FileCollection do
  let(:file1) { parse_ruby('class Foo; end', file_path: '/app/controllers/foo.rb') }
  let(:file2) { parse_ruby('class Bar; end', file_path: '/app/models/bar.rb') }
  let(:collection) { Rubyzen::Collections::FileCollection.new([file1, file2]) }

  describe '#with_paths' do
    it 'filters files by path substring' do
      result = collection.with_paths('controllers/')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('foo.rb')
    end

    it 'supports multiple path patterns' do
      result = collection.with_paths('controllers/', 'models/')
      expect(result.size).to eq(2)
    end
  end

  describe '#without_paths' do
    it 'excludes files matching path' do
      result = collection.without_paths('controllers/')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('bar.rb')
    end
  end

  describe '#classes' do
    it 'returns a ClassesCollection from all files' do
      result = collection.classes
      expect(result).to be_a(Rubyzen::Collections::ClassesCollection)
      expect(result.map(&:name)).to contain_exactly('Foo', 'Bar')
    end
  end

  describe '#modules' do
    it 'returns a ModulesCollection' do
      file = parse_ruby('module Admin; end', file_path: '/app/mod.rb')
      coll = Rubyzen::Collections::FileCollection.new([file])
      expect(coll.modules).to be_a(Rubyzen::Collections::ModulesCollection)
      expect(coll.modules.first.name).to eq('Admin')
    end
  end

  describe '#constants' do
    it 'returns a ConstantsCollection' do
      file = parse_ruby('MAX = 100', file_path: '/app/config.rb')
      coll = Rubyzen::Collections::FileCollection.new([file])
      expect(coll.constants).to be_a(Rubyzen::Collections::ConstantsCollection)
    end
  end

  describe '#requires' do
    it 'returns a RequiresCollection' do
      file = parse_ruby('require "json"', file_path: '/app/init.rb')
      coll = Rubyzen::Collections::FileCollection.new([file])
      expect(coll.requires).to be_a(Rubyzen::Collections::RequiresCollection)
    end
  end

  describe '#call_sites' do
    it 'returns a CallSiteCollection' do
      file = parse_ruby('puts "hi"', file_path: '/app/run.rb')
      coll = Rubyzen::Collections::FileCollection.new([file])
      expect(coll.call_sites).to be_a(Rubyzen::Collections::CallSiteCollection)
    end
  end

  describe '#blocks' do
    it 'returns a BlocksCollection' do
      file = parse_ruby('[1].each { |x| x }', file_path: '/app/run.rb')
      coll = Rubyzen::Collections::FileCollection.new([file])
      expect(coll.blocks).to be_a(Rubyzen::Collections::BlocksCollection)
    end
  end

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = collection.with_name('foo.rb')
      expect(result.size).to eq(1)
    end

    it 'supports with_name_ending_with' do
      result = collection.with_name_ending_with('.rb')
      expect(result.size).to eq(2)
    end

    it 'supports without_name' do
      result = collection.without_name('foo.rb')
      expect(result.size).to eq(1)
    end
  end
end
