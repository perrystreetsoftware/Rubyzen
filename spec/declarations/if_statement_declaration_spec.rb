require 'spec_helper'

RSpec.describe Rubyzen::Declarations::IfStatementDeclaration do
  def if_statements_from(source)
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar
          #{source}
        end
      end
    RUBY
    file.classes.first.instance_methods.first.if_statements
  end

  describe '#condition_source' do
    it 'returns the condition as source code' do
      stmts = if_statements_from("if active?\n  do_something\nend")
      expect(stmts.first.condition_source).to eq('active?')
    end
  end

  describe '#name' do
    it 'returns the parent method name' do
      stmts = if_statements_from("if true\n  1\nend")
      expect(stmts.first.name).to eq('bar')
    end
  end

  describe '#source_code' do
    it 'returns the full if statement source' do
      stmts = if_statements_from("if active?\n  do_something\nend")
      expect(stmts.first.source_code).to include('if active?')
    end
  end

  describe '#line' do
    it 'returns the line number' do
      stmts = if_statements_from("if true\n  1\nend")
      expect(stmts.first.line).to be_a(Integer)
    end
  end

  describe '#class_name' do
    it 'returns the enclosing class name' do
      stmts = if_statements_from("if true\n  1\nend")
      expect(stmts.first.class_name).to eq('Foo')
    end
  end
end
