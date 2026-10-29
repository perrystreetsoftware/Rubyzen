require 'spec_helper'

RSpec.describe 'zen_empty matcher' do
  let(:empty_collection) { Rubyzen::Collections::ClassesCollection.new }
  let(:non_empty_collection) do
    file = parse_ruby('class Foo; end')
    Rubyzen::Collections::ClassesCollection.new(file.classes)
  end

  it 'passes when collection is empty' do
    expect(empty_collection).to zen_empty
  end

  it 'fails when collection is not empty' do
    expect {
      expect(non_empty_collection).to zen_empty
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected to be empty/)
  end

  it 'supports custom failure message' do
    expect {
      expect(non_empty_collection).to zen_empty("Controllers should not have violations")
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Controllers should not have violations/)
  end

  it 'supports negation' do
    expect(non_empty_collection).not_to zen_empty
  end

  describe 'with allowlist' do
    let(:classes) do
      file = parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
        class FooController; end
        class BarController; end
      RUBY
      Rubyzen::Collections::ClassesCollection.new(file.classes)
    end

    it 'passes when all items are allowlisted' do
      expect(classes).to zen_empty(allowlist: ['FooController', 'BarController'])
    end

    it 'fails when there are non-allowlisted items' do
      expect {
        expect(classes).to zen_empty(allowlist: ['FooController'])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /violations/i)
    end

    it 'fails on stale allowlist entries' do
      expect {
        expect(classes).to zen_empty(allowlist: ['FooController', 'BarController', 'NonExistent'])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end

  describe 'with baseline' do
    let(:classes) do
      file = parse_ruby(<<~RUBY, file_path: '/app/controllers/foo_controller.rb')
        class FooController; end
        class BarController; end
      RUBY
      Rubyzen::Collections::ClassesCollection.new(file.classes)
    end

    it 'passes when all items are in baseline' do
      expect(classes).to zen_empty(baseline: ['FooController', 'BarController'])
    end

    it 'fails on stale baseline entries' do
      expect {
        expect(classes).to zen_empty(baseline: ['FooController', 'BarController', 'OldClass'])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end

  describe 'with a rule' do
    let(:rule) do
      Rubyzen::Rule.new(
        description: 'No Foo classes.',
        rationale: 'Foo is deprecated.',
        fix_hint: 'Rename Foo to Bar.'
      )
    end

    it 'shows the rule sections followed by the violations' do
      expect {
        expect(non_empty_collection).to zen_empty(rule:)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
        expect(error.message).to eq(<<~MESSAGE.chomp)
          RULE: No Foo classes.

          WHY: Foo is deprecated.

          HOW TO FIX: Rename Foo to Bar.

          Violations:
            - element: Foo
            - class: Foo
            - file: test.rb:1
        MESSAGE
      }
    end

    it 'shows stale baseline entries after the rule' do
      expect {
        expect(empty_collection).to zen_empty(rule:, baseline: ['OldClass'])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /No Foo classes\.\n\n.*Stale baseline entries:\n  - OldClass/m)
    end

    it 'passes when the collection is empty' do
      expect(empty_collection).to zen_empty(rule:)
    end

    it 'accepts the rule as the positional argument' do
      expect {
        expect(non_empty_collection).to zen_empty(rule)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /\ARULE: No Foo classes\./)
    end

    it 'prefers a custom message over the rule' do
      expect {
        expect(non_empty_collection).to zen_empty('Custom message', rule:)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
        expect(error.message).to start_with('Custom message')
        expect(error.message).not_to include('RULE:')
      }
    end

    it 'rejects a rule that is not a Rubyzen::Rule' do
      expect {
        expect(non_empty_collection).to zen_empty(rule: 'No Foo classes.')
      }.to raise_error(ArgumentError, /Expected rule: to be a Rubyzen::Rule, got String/)
    end
  end
end
