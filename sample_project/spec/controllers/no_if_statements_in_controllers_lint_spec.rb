# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'No if statements in controllers' do
	let(:baseline) { [] }

	let(:target_classes) do
    (controllers + presenters).without_name(*baseline)
  end

  context "given controller classes" do
    it "has no if statements in methods" do
      expect(target_classes.all_methods.if_statements).to zen_empty(rule:)
    end

    it "has no if statements in methods, using true with a block" do
      expect(target_classes.all_methods).to zen_true(rule:) { |m|
        m.if_statements.count.zero?
      }
    end

    it "has no if statements in methods, using false with a block" do
      expect(target_classes.all_methods).to zen_false(rule:) { |m|
        !m.if_statements.count.zero?
      }
    end
  end

  let(:rule) do
    Rubyzen::Rule.new do
      description 'Controllers and presenters do not contain if statements.'
      rationale <<~TEXT
        Controllers only orchestrate a request and presenters only format a response.
        Branching in them hides business logic where it cannot be reused or unit-tested.
      TEXT
      fix_hint 'Move the condition into a Service (or a Question) and call it from the controller.'
      bad_example <<~RUBY
        def index
          if rand > 0.5
            render_success
          end
        end
      RUBY
      good_example <<~RUBY
        def index
          Services::Index.new.call
        end
      RUBY
    end
  end
end
