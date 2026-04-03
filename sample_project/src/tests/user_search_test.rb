# frozen_string_literal: true

RSpec.describe 'User search' do
  let(:complex_query) do
    User
      .where(active: true)
      .where(verified: true)
      .where('created_at > ?', 30.days.ago)
      .order(:name)
      .limit(10)
      .includes(:profile)
      .references(:profile)
  end

  let(:simple_user) { create(:user) }

  it 'should include the simple user in the complex query results' do
    expect(complex_query).to include(simple_user)
  end
end
