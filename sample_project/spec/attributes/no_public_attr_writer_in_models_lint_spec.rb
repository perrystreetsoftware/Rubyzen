require_relative '../spec_helper'

RSpec.describe 'No public attr_writer in domain models' do
  context 'given a domain model' do
    it 'does not expose public attribute writers' do
      expect(models.attributes).to zen_false { |attr| attr.writer? && attr.public? }
    end
  end
end
