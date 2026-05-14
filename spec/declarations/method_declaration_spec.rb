require 'spec_helper'

RSpec.describe Rubyzen::Declarations::MethodDeclaration do
  def first_method(source)
    parse_ruby(source).classes.first.instance_methods.first
  end

  describe '#name' do
    it 'returns the method name' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate; end
        end
      RUBY

      expect(method.name).to eq('calculate')
    end
  end

  describe '#parameters' do
    it 'returns parameter declarations' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate(x, y); end
        end
      RUBY

      expect(method.parameters.map(&:name)).to eq([:x, :y])
    end

    it 'returns empty collection when no parameters' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate; end
        end
      RUBY

      expect(method.parameters).to zen_empty
    end
  end

  describe '#parameters?' do
    it 'returns true when method has parameters' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate(x); end
        end
      RUBY

      expect(method.parameters?).to be true
    end

    it 'returns false when method has no parameters' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate; end
        end
      RUBY

      expect(method.parameters?).to be false
    end
  end

  describe '#call_sites' do
    it 'returns call sites within the method' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate
            User.find(1)
            save
          end
        end
      RUBY

      expect(method.call_sites.map(&:method_name)).to include('find', 'save')
    end
  end

  describe '#blocks' do
    it 'returns blocks within the method' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate
            items.each { |i| puts i }
          end
        end
      RUBY

      expect(method.blocks.map(&:method_name)).to eq(['each'])
    end
  end

  describe '#if_statements' do
    it 'returns if statements within the method' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate
            if active?
              do_something
            end
          end
        end
      RUBY

      expect(method.if_statements.size).to eq(1)
    end
  end

  describe '#lines_of_code' do
    it 'returns the number of lines in the method' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate
            x = 1
            y = 2
            x + y
          end
        end
      RUBY

      expect(method.lines_of_code).to eq(5)
    end
  end

  describe '#visibility' do
    it 'returns :public for public methods' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate; end
        end
      RUBY

      expect(method.visibility).to eq(:public)
      expect(method.public?).to be true
    end

    it 'returns :private for private methods' do
      file = parse_ruby(<<~RUBY)
        class Foo
          private

          def secret; end
        end
      RUBY

      method = file.classes.first.instance_methods.first
      expect(method.visibility).to eq(:private)
      expect(method.private?).to be true
    end

    it 'returns :protected for protected methods' do
      file = parse_ruby(<<~RUBY)
        class Foo
          protected

          def internal; end
        end
      RUBY

      method = file.classes.first.instance_methods.first
      expect(method.visibility).to eq(:protected)
      expect(method.protected?).to be true
    end
  end

  describe '#rescues' do
    it 'returns rescue declarations' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate
            something
          rescue ArgumentError
            handle
          end
        end
      RUBY

      expect(method.rescues.size).to eq(1)
      expect(method.rescues.first.exception_types).to eq(['ArgumentError'])
    end
  end

  describe '#raises' do
    it 'returns raise declarations' do
      method = first_method(<<~RUBY)
        class Foo
          def calculate
            raise RuntimeError, "oops"
          end
        end
      RUBY

      expect(method.raises.size).to eq(1)
    end
  end

  describe '#constants' do
    it 'returns constants referenced in the method' do
      file = parse_ruby(<<~RUBY)
        class Foo
          MAX = 100

          def calculate
            x = MAX
          end
        end
      RUBY

      method = file.classes.first.instance_methods.first
      refs = method.constants.filter(&:reference?)
      expect(refs.map(&:name)).to include('MAX')
    end
  end

  describe '#class_name' do
    it 'returns the parent class name' do
      method = first_method(<<~RUBY)
        class Calculator
          def compute; end
        end
      RUBY

      expect(method.class_name).to eq('Calculator')
    end
  end

  describe '#file_path' do
    it 'returns the file path' do
      file = parse_ruby(<<~RUBY, file_path: '/app/calc.rb')
        class Foo
          def bar; end
        end
      RUBY

      expect(file.classes.first.instance_methods.first.file_path).to eq('/app/calc.rb')
    end
  end
end
