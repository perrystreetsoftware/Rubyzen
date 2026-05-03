require 'spec_helper'

RSpec.describe Rubyzen::Declarations::ConstantDeclaration do
  describe '#name' do
    it 'returns the constant name for assignments' do
      file = parse_ruby(<<~RUBY)
        MAX = 100
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.name).to eq('MAX')
    end

    it 'returns the constant name for references' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar
            MAX
          end
        end
      RUBY

      refs = file.constants.filter(&:reference?)
      expect(refs.map(&:name)).to include('MAX')
    end
  end

  describe '#value' do
    it 'returns string values' do
      file = parse_ruby(<<~RUBY)
        NAME = "hello"
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.value).to eq('hello')
    end

    it 'returns integer values' do
      file = parse_ruby(<<~RUBY)
        MAX = 100
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.value).to eq(100)
    end

    it 'returns boolean values' do
      file = parse_ruby(<<~RUBY)
        ENABLED = true
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.value).to eq(true)
    end

    it 'returns nil for references' do
      file = parse_ruby('class Foo < Bar; end')
      ref = file.constants.filter(&:reference?).first
      expect(ref.value).to be_nil
    end
  end

  describe '#assignment?' do
    it 'returns true for constant assignments' do
      file = parse_ruby(<<~RUBY)
        MAX = 100
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.assignment?).to be true
    end
  end

  describe '#reference?' do
    it 'returns true for constant references' do
      file = parse_ruby('class Foo; end')
      ref = file.constants.filter(&:reference?).first
      expect(ref.reference?).to be true
    end
  end

  describe '#top_level?' do
    it 'returns true for constants defined at file scope' do
      file = parse_ruby(<<~RUBY)
        MAX = 100
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.top_level?).to be true
    end

    it 'returns false for constants inside a class' do
      file = parse_ruby(<<~RUBY)
        class Foo
          MAX = 100
        end
      RUBY

      const = file.constants.filter(&:assignment?).first
      expect(const.top_level?).to be false
    end
  end

  describe '#scoped?' do
    it 'returns the opposite of top_level?' do
      file = parse_ruby(<<~RUBY)
        class Foo
          MAX = 100
        end
      RUBY

      const = file.constants.filter(&:assignment?).first
      expect(const.scoped?).to be true
    end
  end

  describe '#source_code' do
    it 'returns the source' do
      file = parse_ruby(<<~RUBY)
        MAX = 100
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.source_code).to eq('MAX = 100')
    end
  end

  describe '#value with float' do
    it 'returns float values' do
      file = parse_ruby(<<~RUBY)
        RATE = 3.14
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.value).to eq(3.14)
    end
  end

  describe '#in_class?' do
    it 'returns true when inside a class' do
      file = parse_ruby(<<~RUBY)
        class Foo
          MAX = 100
          MIN = 0
        end
      RUBY

      const = file.classes.first.constants.filter(&:assignment?).first
      expect(const.in_class?).to be true
    end

    it 'returns false when at file level' do
      file = parse_ruby(<<~RUBY)
        MAX = 100
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.in_class?).to be false
    end
  end

  describe '#enclosing_class' do
    it 'returns the class declaration when inside a class' do
      file = parse_ruby(<<~RUBY)
        class Foo
          MAX = 100
          MIN = 0
        end
      RUBY

      const = file.classes.first.constants.filter(&:assignment?).first
      expect(const.enclosing_class).to be_a(Rubyzen::Declarations::ClassDeclaration)
    end

    it 'returns nil when at file level' do
      file = parse_ruby(<<~RUBY)
        MAX = 100
        x = 1
      RUBY
      const = file.constants.filter(&:assignment?).first
      expect(const.enclosing_class).to be_nil
    end
  end

  describe '#in_module?' do
    it 'returns true when inside a module' do
      file = parse_ruby(<<~RUBY)
        module Config
          TIMEOUT = 30
          RETRIES = 3
        end
      RUBY

      const = file.modules.first.constants.filter(&:assignment?).first
      expect(const.in_module?).to be true
    end
  end

  describe '#enclosing_module' do
    it 'returns the module declaration when inside a module' do
      file = parse_ruby(<<~RUBY)
        module Config
          TIMEOUT = 30
          RETRIES = 3
        end
      RUBY

      const = file.modules.first.constants.filter(&:assignment?).first
      expect(const.enclosing_module).to be_a(Rubyzen::Declarations::ModuleDeclaration)
    end
  end
end
