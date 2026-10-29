require 'spec_helper'

RSpec.describe Rubyzen::Rule do
  let(:full_rule) do
    described_class.new(
      description: 'Controllers do not contain if statements.',
      rationale: 'Controllers only orchestrate; branching belongs in a Service.',
      fix_hint: 'Move the condition into a Service step.',
      bad_example: 'return error if banned?',
      good_example: 'Services::Update.new.call'
    )
  end

  describe '#initialize' do
    it 'requires a description' do
      expect { described_class.new(rationale: 'Why') }.to raise_error(ArgumentError, /description/)
    end

    it 'rejects a blank description' do
      expect { described_class.new(description: "  \n") }.to raise_error(ArgumentError, /requires a description/)
    end

    it 'is frozen' do
      expect(full_rule).to be_frozen
    end

    it 'strips surrounding whitespace from text sections' do
      rule = described_class.new(description: "  Short rule.\n", rationale: "Because.\n")

      expect(rule.description).to eq('Short rule.')
      expect(rule.rationale).to eq('Because.')
    end

    it 'treats blank optional sections as nil' do
      rule = described_class.new(description: 'Short rule.', rationale: '', fix_hint: "  \n")

      expect(rule.rationale).to be_nil
      expect(rule.fix_hint).to be_nil
    end

    it 'keeps the indentation of heredoc examples' do
      rule = described_class.new(description: 'Short rule.', bad_example: <<~RUBY)
        def call
          return if banned?
        end
      RUBY

      expect(rule.bad_example).to eq("def call\n  return if banned?\nend")
    end
  end

  describe 'block DSL' do
    it 'builds the same rule as the keywords' do
      rule = described_class.new do
        description 'Controllers do not contain if statements.'
        rationale 'Controllers only orchestrate; branching belongs in a Service.'
        fix_hint 'Move the condition into a Service step.'
        bad_example 'return error if banned?'
        good_example 'Services::Update.new.call'
      end

      expect(rule.message).to eq(full_rule.message)
    end

    it 'keeps the indentation of heredoc examples' do
      rule = described_class.new do
        description 'Short rule.'
        bad_example <<~RUBY
          def call
            return if banned?
          end
        RUBY
      end

      expect(rule.bad_example).to eq("def call\n  return if banned?\nend")
    end

    it 'yields the builder to a block that declares a parameter' do
      fix = 'Use the method from the surrounding scope.'
      rule = described_class.new do |r|
        r.description 'Short rule.'
        r.fix_hint fix
      end

      expect(rule.fix_hint).to eq(fix)
    end

    it 'requires a description' do
      expect { described_class.new { rationale 'Why' } }.to raise_error(ArgumentError, /requires a description/)
    end

    it 'rejects keywords and a block together' do
      expect {
        described_class.new(description: 'Short rule.') { fix_hint 'Do this.' }
      }.to raise_error(ArgumentError, /keywords or in a block, not both/)
    end

    it 'rejects unknown sections' do
      expect { described_class.new { description 'Short rule.'; why 'Because.' } }.to raise_error(NoMethodError, /why/)
    end

    it 'is frozen' do
      expect(described_class.new { description 'Short rule.' }).to be_frozen
    end
  end

  describe '#message' do
    it 'renders every provided section, separated by blank lines' do
      expect(full_rule.message).to eq(<<~MESSAGE.chomp)
        RULE: Controllers do not contain if statements.

        WHY: Controllers only orchestrate; branching belongs in a Service.

        HOW TO FIX: Move the condition into a Service step.

        BAD:
        return error if banned?

        GOOD:
        Services::Update.new.call
      MESSAGE
    end

    it 'omits sections that were not provided' do
      rule = described_class.new(description: 'Short rule.', fix_hint: 'Do this.')

      expect(rule.message).to eq("RULE: Short rule.\n\nHOW TO FIX: Do this.")
    end

    it 'is also the string form of the rule' do
      expect(full_rule.to_s).to eq(full_rule.message)
    end
  end
end
