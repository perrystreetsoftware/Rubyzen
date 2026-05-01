require 'spec_helper'

RSpec.describe Rubyzen::Collections::ModulesCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      module Admin
        class UsersController; end

        def helper_method; end

        MAX = 10
      end

      module Api; end
    RUBY
  end

  let(:modules) { Rubyzen::Collections::ModulesCollection.new(file.modules) }

  describe '#all_methods' do
    it 'returns methods from all modules' do
      methods = modules.all_methods
      expect(methods).to be_a(Rubyzen::Collections::MethodsCollection)
      expect(methods.map(&:name)).to include('helper_method')
    end
  end

  describe '#classes' do
    it 'returns classes from all modules' do
      classes = modules.classes
      expect(classes).to be_a(Rubyzen::Collections::ClassesCollection)
      expect(classes.map(&:name_without_modules)).to include('UsersController')
    end
  end

  describe '#constants' do
    it 'returns constants from all modules' do
      constants = modules.constants
      expect(constants).to be_a(Rubyzen::Collections::ConstantsCollection)
    end
  end

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = modules.with_name('Admin')
      expect(result.size).to eq(1)
    end
  end
end
