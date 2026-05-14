# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'No if statements in controllers' do
	let(:baseline) { [] }

	let(:target_classes) do
    (controllers + presenters).without_name(*baseline)
  end

  context "given controller classes" do
    it "has no if statements in methods" do
      expect(target_classes.all_methods.if_statements).to zen_empty
    end

    it "has no if statements in methods, using true with a block" do
      expect(target_classes.all_methods).to zen_true { |m|
        m.if_statements.count.zero?
      }
    end

    it "has no if statements in methods, using false with a block" do
      expect(target_classes.all_methods).to zen_false { |m|
        !m.if_statements.count.zero?
      }
    end
  end
end
