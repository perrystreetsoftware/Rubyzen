# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'No generic errors in classes' do
  context 'given a class' do
    it 'does not raise a runtime error' do
      expect(all_classes.raises.with_exception_type('RuntimeError')).to be_empty
    end

    it 'does not raise using a string' do
      expect(all_classes.raises.with_string).to be_empty
    end

    it 'does not rescue a runtime error' do
      expect(all_classes.rescues.with_exception_type('RuntimeError')).to be_empty
    end

    it 'does not rescue a standard error' do
      expect(all_classes.rescues.with_exception_type('StandardError')).to be_empty
    end
  end
end
