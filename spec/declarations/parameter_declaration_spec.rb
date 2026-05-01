require 'spec_helper'

RSpec.describe Rubyzen::Declarations::ParameterDeclaration do
  describe '#name' do
    it 'returns the parameter name' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar(name, age); end
        end
      RUBY

      params = file.classes.first.instance_methods.first.parameters
      expect(params.map(&:name)).to eq([:name, :age])
    end
  end

  describe '#default_value' do
    it 'returns the default value when present' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar(x = 42); end
        end
      RUBY

      param = file.classes.first.instance_methods.first.parameters.first
      expect(param.default_value).to eq(42)
    end

    it 'returns nil when no default value' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar(x); end
        end
      RUBY

      param = file.classes.first.instance_methods.first.parameters.first
      expect(param.default_value).to be_nil
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      file = parse_ruby(<<~RUBY)
        class Calculator
          def compute(x); end
        end
      RUBY

      param = file.classes.first.instance_methods.first.parameters.first
      expect(param.class_name).to eq('Calculator')
    end
  end

  describe '#file_path' do
    it 'returns the file path' do
      file = parse_ruby(<<~RUBY, file_path: '/app/calc.rb')
        class Foo
          def bar(x); end
        end
      RUBY

      param = file.classes.first.instance_methods.first.parameters.first
      expect(param.file_path).to eq('/app/calc.rb')
    end
  end

  describe '#line' do
    it 'returns the line number' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar(x); end
        end
      RUBY

      param = file.classes.first.instance_methods.first.parameters.first
      expect(param.line).to be_a(Integer)
    end
  end
end
