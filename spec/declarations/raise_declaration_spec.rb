require 'spec_helper'

RSpec.describe Rubyzen::Declarations::RaiseDeclaration do
  def raises_from(source)
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          #{source}
        end
      end
    RUBY
    file.classes.first.instance_methods.first.raises
  end

  describe '#exception_types' do
    it 'returns the exception class for raise with constant' do
      raises = raises_from('raise ArgumentError, "bad"')
      expect(raises.first.exception_types).to eq(['ArgumentError'])
    end

    it 'returns RuntimeError for bare raise with string' do
      raises = raises_from('raise "something went wrong"')
      expect(raises.first.exception_types).to eq(['RuntimeError'])
    end

    it 'returns RuntimeError for bare raise' do
      raises = raises_from('raise')
      expect(raises.first.exception_types).to eq(['RuntimeError'])
    end

    it 'handles raise with .new' do
      raises = raises_from('raise ArgumentError.new("bad")')
      expect(raises.first.exception_types).to eq(['ArgumentError'])
    end
  end

  describe '#with_string?' do
    it 'returns true when raising with a string' do
      raises = raises_from('raise "oops"')
      expect(raises.first.with_string?).to be true
    end

    it 'returns false when raising with an exception class' do
      raises = raises_from('raise ArgumentError, "bad"')
      expect(raises.first.with_string?).to be false
    end
  end

  describe '#message' do
    it 'returns the string message for bare string raises' do
      raises = raises_from('raise "something went wrong"')
      expect(raises.first.message).to eq('something went wrong')
    end

    it 'returns the message for exception class raises' do
      raises = raises_from('raise ArgumentError, "bad input"')
      expect(raises.first.message).to eq('bad input')
    end

    it 'returns the message for .new raises' do
      raises = raises_from('raise ArgumentError.new("bad input")')
      expect(raises.first.message).to eq('bad input')
    end

    it 'returns nil when no message' do
      raises = raises_from('raise')
      expect(raises.first.message).to be_nil
    end
  end

  describe '#source_code' do
    it 'returns the raise source' do
      raises = raises_from('raise ArgumentError, "bad"')
      expect(raises.first.source_code).to include('raise')
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      raises = raises_from('raise "oops"')
      expect(raises.first.class_name).to eq('Foo')
    end
  end
end
