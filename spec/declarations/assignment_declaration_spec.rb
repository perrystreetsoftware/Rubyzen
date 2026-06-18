require 'spec_helper'

RSpec.describe Rubyzen::Declarations::AssignmentDeclaration do
  def method_from(body)
    file = parse_ruby(<<~RUBY)
      class Q
        def go
          #{body}
        end
      end
    RUBY
    file.classes.first.instance_methods.first
  end

  it 'exposes the variable name and the constructor value' do
    method = method_from("x = Repos::Foo.new\n        x.create(1)")
    assignment = method.assignments.first
    expect(assignment.name).to eq('x')
    expect(assignment.value.constructor?).to be(true)
    expect(assignment.value.constant_name).to eq('Repos::Foo')
  end

  it 'collects every local-variable assignment in the method' do
    method = method_from("a = 1\n        b = 2")
    expect(method.assignments.map(&:name)).to contain_exactly('a', 'b')
  end

  it 'returns a nil value for a multiple-assignment target (no value node)' do
    method = method_from("a, b = build_pair\n        a")
    by_name = method.assignments.to_h { |assignment| [assignment.name, assignment] }
    expect(by_name['a'].value).to be_nil
    expect(by_name['b'].value).to be_nil
  end

  describe 'inside a block' do
    it 'collects block-local assignments, aggregated through the collection bridge' do
      file = parse_ruby(<<~RUBY)
        run do
          repo = Repos::Foo.new
          repo
        end
        sentinel = 1
      RUBY
      assignment = file.blocks.assignments.first
      expect(assignment.name).to eq('repo')
      expect(assignment.value.constant_name).to eq('Repos::Foo')
    end
  end
end
