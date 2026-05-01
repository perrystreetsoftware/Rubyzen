require 'spec_helper'

RSpec.describe Rubyzen::Collections::RaisesCollection do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        def bar
          raise "string error"
          raise ArgumentError, "bad"
        end
      end
    RUBY
  end

  let(:raises) { file.classes.first.instance_methods.first.raises }

  describe '#with_string' do
    it 'filters to raises with string messages' do
      result = raises.with_string
      expect(result.size).to eq(1)
      expect(result.first.message).to eq('string error')
    end
  end

  describe '#with_exception_type' do
    it 'filters by exception class' do
      result = raises.with_exception_type('ArgumentError')
      expect(result.size).to eq(1)
    end

    it 'returns empty for non-matching type' do
      result = raises.with_exception_type('TypeError')
      expect(result).to be_empty
    end
  end
end
