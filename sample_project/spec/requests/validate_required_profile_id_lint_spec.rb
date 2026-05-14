# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Requests validate required profile id' do
  context 'given a request that uses validates_required' do
    it 'validates required profile id' do
      expect(requests.with_macro_name('validates_required')).to zen_true { |klass|
        klass.macros.with_name('validates_required').any? do |macro|
          macro.symbols.include?(:profile_id)
        end
      }
    end
  end
end
