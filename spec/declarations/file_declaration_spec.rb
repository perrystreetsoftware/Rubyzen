require 'spec_helper'

RSpec.describe Rubyzen::Declarations::FileDeclaration do
  describe '#name' do
    it 'returns the basename of the file path' do
      file = parse_ruby('class Foo; end', file_path: '/app/models/user.rb')
      expect(file.name).to eq('user.rb')
    end
  end

  describe '#path' do
    it 'returns the full file path' do
      file = parse_ruby('class Foo; end', file_path: '/app/models/user.rb')
      expect(file.path).to eq('/app/models/user.rb')
    end
  end

  describe '#classes' do
    it 'returns all classes in the file' do
      file = parse_ruby(<<~RUBY)
        class Foo; end
        class Bar; end
      RUBY

      expect(file.classes.map(&:name)).to eq(%w[Foo Bar])
    end

    it 'returns empty array when no classes exist' do
      file = parse_ruby('x = 1')
      expect(file.classes).to zen_empty
    end
  end

  describe '#modules' do
    it 'returns all modules in the file' do
      file = parse_ruby(<<~RUBY)
        module Foo
          module Bar; end
        end
      RUBY

      expect(file.modules.map(&:name_without_modules)).to include('Foo', 'Bar')
    end
  end

  describe '#top_level_module_name' do
    it 'returns the first module name' do
      file = parse_ruby(<<~RUBY)
        module MyApp
          class Foo; end
        end
      RUBY

      expect(file.top_level_module_name).to eq('MyApp')
    end

    it 'returns nil when no modules exist' do
      file = parse_ruby('class Foo; end')
      expect(file.top_level_module_name).to be_nil
    end
  end

  describe '#lines_of_code' do
    it 'counts the number of lines' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar; end
        end
      RUBY
      expect(file.lines_of_code).to eq(3)
    end
  end

  describe '#constants' do
    it 'returns constants in the file' do
      file = parse_ruby(<<~RUBY)
        MAX = 100
        class Foo; end
      RUBY

      assignments = file.constants.filter(&:assignment?)
      expect(assignments.map(&:name)).to include('MAX')
    end
  end

  describe '#requires' do
    it 'returns require statements' do
      file = parse_ruby(<<~RUBY)
        require 'json'
        require_relative 'helper'
      RUBY

      expect(file.requires.size).to eq(2)
      expect(file.requires.map(&:required_path)).to eq(%w[json helper])
    end
  end

  describe '#call_sites' do
    it 'returns all call sites in the file' do
      file = parse_ruby(<<~RUBY)
        puts "hello"
        foo.bar
      RUBY

      expect(file.call_sites.map(&:method_name)).to include('puts', 'bar')
    end
  end

  describe '#blocks' do
    it 'returns all blocks in the file' do
      file = parse_ruby(<<~RUBY)
        [1, 2].each do |x|
          puts x
        end
        x = 1
      RUBY

      expect(file.blocks.map(&:method_name)).to eq(['each'])
    end
  end

  describe '#file_path' do
    it 'returns the path via FilePathProvider' do
      file = parse_ruby('x = 1', file_path: '/app/test.rb')
      expect(file.file_path).to eq('/app/test.rb')
    end
  end
end
