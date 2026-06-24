require 'spec_helper'

RSpec.describe Rubyzen::Declarations::ReturnDeclaration do
  def method_from(body)
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          #{body}
        end
      end
    RUBY
    file.classes.first.instance_methods.first
  end

  describe 'the implicit final expression' do
    it 'wraps the body itself for a single-statement method' do
      returns = method_from('{ id: 1 }').returns
      expect(returns.size).to eq(1)
      expect(returns.first.implicit?).to be(true)
      expect(returns.first.explicit?).to be(false)
      expect(returns.first.expression.hash_literal?).to be(true)
    end

    it 'wraps the last statement of a multi-statement body' do
      returns = method_from("log\n        { id: 1 }").returns
      expect(returns.size).to eq(1)
      expect(returns.first.expression.hash_literal?).to be(true)
    end

    it 'wraps the last statement inside an explicit begin..end (kwbegin) body' do
      returns = method_from("begin\n          log\n          { id: 1 }\n        end").returns
      expect(returns.size).to eq(1)
      expect(returns.first.expression.hash_literal?).to be(true)
    end
  end

  describe 'an explicit return' do
    it 'unwraps the returned value and never surfaces the return node itself' do
      returns = method_from('return { id: 1 }').returns
      expect(returns.size).to eq(1)
      expect(returns.first.explicit?).to be(true)
      expect(returns.first.expression.hash_literal?).to be(true)
    end

    it 'is counted once when it is also the final statement of the body' do
      returns = method_from("log\n        return { id: 1 }").returns
      expect(returns.size).to eq(1)
      expect(returns.first.explicit?).to be(true)
      expect(returns.first.expression.hash_literal?).to be(true)
    end

    it 'has a nil expression for a bare return' do
      returns = method_from('return').returns
      expect(returns.size).to eq(1)
      expect(returns.first.explicit?).to be(true)
      expect(returns.first.expression).to be_nil
    end
  end
end
