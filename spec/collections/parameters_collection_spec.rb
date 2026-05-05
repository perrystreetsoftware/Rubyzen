require 'spec_helper'

RSpec.describe Rubyzen::Collections::ParametersCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        def bar(name, age); end
      end
    RUBY
  end

  let(:parameters) { file.classes.first.instance_methods.first.parameters }

  describe 'CollectionFilterProvider' do
    it 'supports with_name' do
      result = parameters.with_name(:name)
      expect(result.size).to eq(1)
    end

    it 'supports without_name' do
      result = parameters.without_name(:name)
      expect(result.size).to eq(1)
      expect(result.first.name).to eq(:age)
    end
  end
end
