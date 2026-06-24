require 'spec_helper'

RSpec.describe Rubyzen::Collections::ExpressionsCollection do
  def return_expressions_of(body)
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          #{body}
        end
      end
    RUBY
    file.classes.first.instance_methods.first.return_expressions
  end

  it '#hash_literals keeps only hash-literal expressions' do
    expressions = return_expressions_of("log\n        { id: 1 }")
    expect(expressions.hash_literals).not_to be_empty
    expect(expressions.hash_literals).to all(satisfy(&:hash_literal?))
  end

  it '#constants keeps bare-constant expressions' do
    expressions = return_expressions_of('SomeConstant')
    expect(expressions.constants.map(&:constant_name)).to eq(['SomeConstant'])
  end

  it '#constants also keeps constructor-of-constant expressions (e.g. Repos::Foo.new)' do
    expressions = return_expressions_of('Repos::Foo.new')
    expect(expressions.constants.map(&:constant_name)).to eq(['Repos::Foo'])
  end

  it 'filter methods return the same collection type' do
    expressions = return_expressions_of("log\n        { id: 1 }")
    expect(expressions.hash_literals).to be_a(described_class)
    expect(expressions.constants).to be_a(described_class)
  end
end
