require 'spec_helper'

RSpec.describe Rubyzen::Collections::BlocksCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        def bar
          items.each { |i| i.save }
          users.map { |u| u.name }
        end
      end
    RUBY
  end

  let(:blocks) { file.classes.first.instance_methods.first.blocks }

  describe '#with_method_name' do
    it 'filters blocks by the method they are passed to' do
      result = blocks.with_method_name('each')
      expect(result.size).to eq(1)
    end
  end

  describe '#call_sites' do
    it 'returns all call sites across blocks' do
      sites = blocks.call_sites
      expect(sites).to be_a(Rubyzen::Collections::CallSiteCollection)
      expect(sites.map(&:method_name)).to include('save', 'name')
    end
  end

  describe '#returns' do
    it 'returns all return points across blocks' do
      returns = blocks.returns
      expect(returns).to be_a(Rubyzen::Collections::ReturnsCollection)
      expect(returns).not_to be_empty
      expect(returns).to all(be_a(Rubyzen::Declarations::ReturnDeclaration))
    end
  end

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = blocks.with_name('each')
      expect(result.size).to eq(1)
    end
  end
end
