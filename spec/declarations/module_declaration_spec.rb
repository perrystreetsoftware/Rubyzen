require 'spec_helper'

RSpec.describe Rubyzen::Declarations::ModuleDeclaration do
  describe '#name' do
    it 'returns the module name' do
      file = parse_ruby('module Controllers; end')
      expect(file.modules.first.name).to eq('Controllers')
    end

    it 'includes parent module names' do
      file = parse_ruby(<<~RUBY)
        module Admin
          module Api; end
        end
      RUBY

      nested = file.modules.find { |m| m.name_without_modules == 'Api' }
      expect(nested.name).to eq('Admin::Api')
    end
  end

  describe '#name_without_modules' do
    it 'returns just the module name' do
      file = parse_ruby(<<~RUBY)
        module Admin
          module Api; end
        end
      RUBY

      nested = file.modules.find { |m| m.name_without_modules == 'Api' }
      expect(nested.name_without_modules).to eq('Api')
    end
  end

  describe '#classes' do
    it 'returns classes within the module' do
      file = parse_ruby(<<~RUBY)
        module Admin
          class UsersController; end
        end
      RUBY

      mod = file.modules.first
      expect(mod.classes.map(&:name_without_modules)).to eq(['UsersController'])
    end
  end

  describe '#modules' do
    it 'returns nested modules' do
      file = parse_ruby(<<~RUBY)
        module Admin
          module V2; end
        end
      RUBY

      mod = file.modules.first
      expect(mod.modules.map(&:name_without_modules)).to include('V2')
    end
  end

  describe '#all_methods' do
    it 'returns methods defined directly in the module' do
      file = parse_ruby(<<~RUBY)
        module Helpers
          def format_date; end
          def format_time; end
        end
      RUBY

      mod = file.modules.first
      expect(mod.all_methods.map(&:name)).to eq(%w[format_date format_time])
    end
  end

  describe '#constants' do
    it 'returns constants in the module' do
      file = parse_ruby(<<~RUBY)
        module Config
          TIMEOUT = 30
        end
      RUBY

      mod = file.modules.first
      assignments = mod.constants.filter(&:assignment?)
      expect(assignments.map(&:name)).to include('TIMEOUT')
    end
  end

  describe '#attributes' do
    it 'returns attributes in the module' do
      file = parse_ruby(<<~RUBY)
        module Helpers
          attr_reader :logger
        end
      RUBY

      mod = file.modules.first
      expect(mod.attributes.first.symbols).to eq(['logger'])
    end
  end

  describe '#lines_of_code' do
    it 'returns the line count' do
      file = parse_ruby(<<~RUBY)
        module Foo
          def bar; end
        end
      RUBY
      expect(file.modules.first.lines_of_code).to eq(3)
    end
  end

  describe '#file_path' do
    it 'returns the file path' do
      file = parse_ruby('module Foo; end', file_path: '/app/foo.rb')
      expect(file.modules.first.file_path).to eq('/app/foo.rb')
    end
  end
end
