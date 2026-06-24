# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Methods named _data or _dto return Data objects, not Hash literals' do
  context 'given source classes' do
    it 'does not return a Hash literal as the final expression' do
      expect(
        all_classes.all_methods
          .filter { |m| m.public? && m.name&.end_with?('_data', '_dto') }
          .filter { |m| m.return_expressions.hash_literals.any? }
      ).to zen_empty
    end
  end
end
