require 'spec_helper'

RSpec.describe Rubyzen::Declarations::ExpressionDeclaration do
  def first_call(source, name)
    parse_ruby("#{source}\nsentinel = 1").call_sites.with_name(name).first
  end

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

  describe 'kind predicates via a call-site receiver' do
    it 'recognizes a bare constant' do
      expr = first_call('Repos::Foo.find(1)', 'find').receiver_expression
      expect(expr.constant?).to be(true)
      expect(expr.constant_name).to eq('Repos::Foo')
      expect(expr.name).to eq('Repos::Foo')
    end

    it 'recognizes a constructor (Const.new) and resolves its constant' do
      expr = first_call('Repos::Foo.new.create(1)', 'create').receiver_expression
      expect(expr.constructor?).to be(true)
      expect(expr.method_call?).to be(true)
      expect(expr.constant_name).to eq('Repos::Foo')
    end

    it 'recognizes a local-variable receiver' do
      file = parse_ruby("x = Repos::Foo.new\nx.create(1)")
      expr = file.call_sites.with_name('create').first.receiver_expression
      expect(expr.local_variable?).to be(true)
      expect(expr.name).to eq('x')
    end
  end

  describe 'kind predicates via call-site arguments' do
    it 'exposes a constant argument name' do
      expr = first_call('allow(Repos::Foo)', 'allow').arguments.first
      expect(expr.constant?).to be(true)
      expect(expr.constant_name).to eq('Repos::Foo')
    end

    it 'returns nil constant_name for a non-constant argument' do
      expr = first_call('allow(thing)', 'allow').arguments.first
      expect(expr.constant_name).to be_nil
    end
  end

  describe '#hash_literal? via a method return expression' do
    it 'is true for a braced hash literal as the final expression' do
      method = method_from("log\n        { id: 1 }")
      expect(method.return_expressions.hash_literals).not_to be_empty
    end

    it 'is false for a Data constructor return' do
      method = method_from('UserData.new(id: 1)')
      expect(method.return_expressions.hash_literals).to be_empty
    end
  end

  describe '#hash_literal? via a block final expression' do
    it 'detects a hash literal returned by a block, through the collection bridge' do
      file = parse_ruby(<<~RUBY)
        build do
          log
          { id: 1 }
        end
        sentinel = 1
      RUBY
      expect(file.blocks.return_expressions.hash_literals).not_to be_empty
    end
  end
end
