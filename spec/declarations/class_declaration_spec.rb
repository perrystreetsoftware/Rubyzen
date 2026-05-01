require 'spec_helper'

RSpec.describe Rubyzen::Declarations::ClassDeclaration do
  describe '#name' do
    it 'returns the class name' do
      file = parse_ruby('class UserController; end')
      expect(file.classes.first.name).to eq('UserController')
    end

    it 'includes parent module names' do
      file = parse_ruby(<<~RUBY)
        module Admin
          class UserController; end
        end
      RUBY

      expect(file.classes.first.name).to eq('Admin::UserController')
    end

    it 'includes nested module names' do
      file = parse_ruby(<<~RUBY)
        module Admin
          module V2
            class UserController; end
          end
        end
      RUBY

      expect(file.classes.first.name).to eq('Admin::V2::UserController')
    end
  end

  describe '#name_without_modules' do
    it 'returns just the class name' do
      file = parse_ruby(<<~RUBY)
        module Admin
          class UserController; end
        end
      RUBY

      expect(file.classes.first.name_without_modules).to eq('UserController')
    end
  end

  describe '#superclass_name' do
    it 'returns the superclass name' do
      file = parse_ruby('class Foo < Bar; end')
      expect(file.classes.first.superclass_name).to eq('Bar')
    end

    it 'returns nil when no superclass' do
      file = parse_ruby('class Foo; end')
      expect(file.classes.first.superclass_name).to be_nil
    end
  end

  describe '#superclass_prefix?' do
    it 'returns true when superclass starts with prefix' do
      file = parse_ruby('class Foo < ApplicationController; end')
      expect(file.classes.first.superclass_prefix?('Application')).to be true
    end

    it 'returns false when superclass does not match' do
      file = parse_ruby('class Foo < Bar; end')
      expect(file.classes.first.superclass_prefix?('Application')).to be false
    end
  end

  describe '#instance_methods' do
    it 'returns instance methods' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar; end
          def baz; end
        end
      RUBY

      methods = file.classes.first.instance_methods
      expect(methods.map(&:name)).to eq(%w[bar baz])
    end

    it 'excludes class methods' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def self.class_method; end
          def instance_method; end
        end
      RUBY

      methods = file.classes.first.instance_methods
      expect(methods.map(&:name)).to eq(%w[instance_method])
    end
  end

  describe '#class_methods' do
    it 'returns self. methods' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def self.build; end
        end
      RUBY

      expect(file.classes.first.class_methods.map(&:name)).to eq(%w[build])
    end

    it 'returns methods from class << self blocks' do
      file = parse_ruby(<<~RUBY)
        class Foo
          class << self
            def build; end
          end
        end
      RUBY

      expect(file.classes.first.class_methods.map(&:name)).to eq(%w[build])
    end
  end

  describe '#called_method_names' do
    it 'returns unique method names called in the class' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            puts "hello"
            save
            puts "world"
          end
        end
      RUBY

      names = file.classes.first.called_method_names
      expect(names).to include('puts', 'save')
    end
  end

  describe '#top_level_module' do
    it 'returns the top level module name from the file' do
      file = parse_ruby(<<~RUBY)
        module Controllers
          class Index; end
        end
      RUBY

      expect(file.classes.first.top_level_module).to eq('Controllers')
    end
  end

  describe '#attributes' do
    it 'returns attribute declarations' do
      file = parse_ruby(<<~RUBY)
        class Foo
          attr_reader :name
          attr_accessor :email
        end
      RUBY

      attrs = file.classes.first.attributes
      expect(attrs.map(&:name)).to eq(%w[attr_reader attr_accessor])
    end
  end

  describe '#macros' do
    it 'returns macro declarations' do
      file = parse_ruby(<<~RUBY)
        class Foo
          validates_required :name
          belongs_to :user
        end
      RUBY

      macros = file.classes.first.macros
      expect(macros.map(&:name)).to include('validates_required', 'belongs_to')
    end
  end

  describe '#lines_of_code' do
    it 'returns the number of lines' do
      file = parse_ruby("class Foo\n  def bar; end\nend")
      expect(file.classes.first.lines_of_code).to eq(3)
    end
  end

  describe '#file_path' do
    it 'returns the file path from the file declaration' do
      file = parse_ruby('class Foo; end', file_path: '/app/foo.rb')
      expect(file.classes.first.file_path).to eq('/app/foo.rb')
    end
  end

  describe '#if_statements' do
    it 'returns if statements within the class' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            if condition
              something
            end
          end
        end
      RUBY

      expect(file.classes.first.if_statements.size).to eq(1)
    end
  end

  describe '#rescues' do
    it 'returns rescue declarations' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            something
          rescue StandardError
            handle
          end
        end
      RUBY

      expect(file.classes.first.rescues.size).to eq(1)
    end
  end

  describe '#raises' do
    it 'returns raise declarations' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            raise ArgumentError, "bad"
          end
        end
      RUBY

      expect(file.classes.first.raises.size).to eq(1)
    end
  end

  describe '#blocks' do
    it 'returns blocks within the class' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            items.each { |i| i }
          end
        end
      RUBY

      expect(file.classes.first.blocks.size).to eq(1)
      expect(file.classes.first.blocks.first.method_name).to eq('each')
    end
  end

  describe '#constants' do
    it 'returns constants within the class' do
      file = parse_ruby(<<~RUBY)
        class Foo
          MAX = 100
          MIN = 0
        end
      RUBY

      assignments = file.classes.first.constants.filter(&:assignment?)
      expect(assignments.map(&:name)).to include('MAX', 'MIN')
    end
  end

  describe '#class_name' do
    it 'returns its own name' do
      file = parse_ruby('class Calculator; end')
      expect(file.classes.first.class_name).to eq('Calculator')
    end
  end
end
