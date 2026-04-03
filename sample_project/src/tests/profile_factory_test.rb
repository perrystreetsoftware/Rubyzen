# frozen_string_literal: true

RSpec.describe 'Profile factory tests' do
  context 'with lat long' do
    let(:some_profile) { create(:profile, latitude: 40.753297, longitude: -73.980845) }

    it 'creates a valid profile' do
      expect(some_profile.latitude).to eq(40.753297)
      expect(some_profile.longitude).to eq(-73.980845)
    end
  end

  context 'with a location trait' do
    let(:some_profile) { create(:profile, :brooklyn) }

    it 'creates a valid profile' do
      expect(some_profile.latitude).to eq(40.6782)
      expect(some_profile.longitude).to eq(-73.9442)
    end
  end
end
