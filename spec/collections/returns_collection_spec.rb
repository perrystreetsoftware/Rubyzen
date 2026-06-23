require 'spec_helper'

RSpec.describe Rubyzen::Collections::ReturnsCollection do
  def returns_of(body)
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          #{body}
        end
      end
    RUBY
    file.classes.first.instance_methods.first.returns
  end

  describe '#expressions' do
    it 'returns an ExpressionsCollection' do
      expect(returns_of('{ id: 1 }').expressions)
        .to be_a(Rubyzen::Collections::ExpressionsCollection)
    end

    it 'exposes the value expressions, filterable with #hash_literals' do
      expressions = returns_of("log\n        { id: 1 }").expressions
      expect(expressions.hash_literals).not_to be_empty
    end

    it 'omits bare returns that have no value' do
      expressions = returns_of("return unless ready\n        { id: 1 }").expressions
      expect(expressions.size).to eq(1)
      expect(expressions.first.hash_literal?).to be(true)
    end
  end

  it 'supports name-based filtering from CollectionFilterProvider' do
    expect(returns_of('{ id: 1 }')).to respond_to(:with_name)
  end
end
