require 'spec_helper'

RSpec.describe Rubyzen::Collections::MethodsCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        def bar(x)
          if active?
            User.find(x)
          end
        end

        def baz
          raise "oops"
        rescue StandardError
          handle
        end
      end
    RUBY
  end

  let(:methods) { file.classes.first.instance_methods }

  describe '#parameters' do
    it 'returns all parameters across methods' do
      params = methods.parameters
      expect(params).to be_a(Rubyzen::Collections::ParametersCollection)
      expect(params.map(&:name)).to include(:x)
    end
  end

  describe '#if_statements' do
    it 'returns all if statements across methods' do
      stmts = methods.if_statements
      expect(stmts).to be_a(Rubyzen::Collections::DeclarationCollection)
      expect(stmts.size).to eq(1)
    end
  end

  describe '#call_sites' do
    it 'returns all call sites across methods' do
      sites = methods.call_sites
      expect(sites).to be_a(Rubyzen::Collections::CallSiteCollection)
      expect(sites.map(&:method_name)).to include('find')
    end
  end

  describe '#rescues' do
    it 'returns all rescues across methods' do
      rescues = methods.rescues
      expect(rescues).to be_a(Rubyzen::Collections::RescuesCollection)
      expect(rescues.size).to eq(1)
    end
  end

  describe '#raises' do
    it 'returns all raises across methods' do
      raises = methods.raises
      expect(raises).to be_a(Rubyzen::Collections::RaisesCollection)
      expect(raises.size).to eq(1)
    end
  end

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = methods.with_name('bar')
      expect(result.size).to eq(1)
    end

    it 'supports without_name' do
      result = methods.without_name('bar')
      expect(result.size).to eq(1)
      expect(result.first.name).to eq('baz')
    end
  end
end
