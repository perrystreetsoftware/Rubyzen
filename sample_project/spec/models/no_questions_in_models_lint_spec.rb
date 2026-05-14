# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'No questions in models' do
  context "given a class that resides in models" do
    let(:question_methods) { models.all_methods.filter { |m| m.name.end_with?('?')} }

    it "does not have questions in it" do
      expect(question_methods).to zen_empty
    end
  end
end
