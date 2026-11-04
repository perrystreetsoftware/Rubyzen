require 'spec_helper'

RSpec.describe 'zen_false matcher' do
  let(:file) do
    parse_ruby(<<~RUBY)
      class Foo
        def bar; end
        def baz; end
      end
    RUBY
  end

  let(:methods) { file.classes.first.instance_methods }

  it 'passes when block returns false for all elements' do
    expect(methods).to zen_false { |m| m.parameters? }
  end

  it 'fails when block returns true for any element' do
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar(x); end
        def baz; end
      end
    RUBY

    methods = file.classes.first.instance_methods
    expect {
      expect(methods).to zen_false { |m| m.parameters? }
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected to return false for all elements/)
  end

  it 'fails when no block is given' do
    expect {
      expect(methods).to zen_false
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected a block/)
  end

  it 'supports custom failure message' do
    file = parse_ruby(<<~RUBY)
      class Foo
        def bar(x); end
      end
    RUBY

    methods = file.classes.first.instance_methods
    expect {
      expect(methods).to zen_false("No methods should have params") { |m| m.parameters? }
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /No methods should have params/)
  end

  describe 'with allowlist' do
    it 'passes when failing items are allowlisted' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar(x); end
          def baz; end
        end
      RUBY

      methods = file.classes.first.instance_methods
      expect(methods).to zen_false(allowlist: ['bar']) { |m| m.parameters? }
    end

    it 'fails on stale allowlist entries' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar; end
          def baz; end
        end
      RUBY

      methods = file.classes.first.instance_methods
      expect {
        expect(methods).to zen_false(allowlist: ['nonexistent']) { |m| m.parameters? }
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end

  describe 'with baseline' do
    it 'passes when failing items are in baseline' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar(x); end
          def baz; end
        end
      RUBY

      methods = file.classes.first.instance_methods
      expect(methods).to zen_false(baseline: ['bar']) { |m| m.parameters? }
    end

    it 'fails on stale baseline entries' do
      file = parse_ruby(<<~RUBY)
        class Foo
          def bar; end
          def baz; end
        end
      RUBY

      methods = file.classes.first.instance_methods
      expect {
        expect(methods).to zen_false(baseline: ['ghost']) { |m| m.parameters? }
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /stale/i)
    end
  end

  describe 'with a rule' do
    let(:rule) { Rubyzen::Rule.new(description: 'Methods take parameters.', fix_hint: 'Add a parameter.') }
    let(:methods) do
      parse_ruby(<<~SOURCE).classes.first.instance_methods
        class Foo
          def bar(x); end
          def baz; end
        end
      SOURCE
    end

    it 'shows the rule sections followed by the violations' do
      failing = methods.with_name('bar')

      expect {
        expect(failing).to zen_false(rule:) { |m| m.parameters? }
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError) { |error|
        expect(error.message).to eq(<<~MESSAGE.chomp)
          RULE: Methods take parameters.

          HOW TO FIX: Add a parameter.

          Violations:
            - element: bar
            - class: Foo
            - file: test.rb:2
        MESSAGE
      }
    end

    it 'baselines violations like any other message' do
      expect(methods).to zen_false(rule:, baseline: ['bar']) { |m| m.parameters? }
    end

    it 'prefers a custom message over the rule' do
      expect {
        expect(methods).to zen_false('Custom message', rule:) { |m| m.parameters? }
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /\ACustom message\n/)
    end

    it 'keeps the missing block reason after the rule' do
      expect {
        expect(methods).to zen_false(rule:)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                       /\ARULE: Methods take parameters\..*\n\nExpected a block, but got nil\.\z/m)
    end
  end
end
