require 'rspec'
require 'rubyzen'
require 'pry'
require_relative '../spec_helper'

RSpec.describe 'No if statements in controllers' do
	let(:baseline) { [] }

	let(:target_classes) do
    (controller_classes + presenters).without_pathname(baseline)
  end

  context "given controller classes" do
    it "has no if statements in methods" do
      expect(target_classes.all_methods.if_statements).to be_zen_empty
    end

    it "has no if statements in methods, using zen_true with a block" do
      expect(target_classes.all_methods).to be_zen_true { |m|
        m.if_statements.count.zero?
      }
    end

    it "has no if statements in methods, using zen_false with a block" do
      expect(target_classes.all_methods).to be_zen_false { |m|
        !m.if_statements.count.zero?
      }
    end

  end
end
