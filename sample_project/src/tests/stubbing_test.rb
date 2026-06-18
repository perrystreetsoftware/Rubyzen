# frozen_string_literal: true

RSpec.describe 'Stubbing repos' do
  before do
    # Violation: stubbing a core domain class (a Repos constant).
    allow(Repos::User).to receive(:find).and_return(nil)
  end

  it 'does something' do
    expect(true).to be(true)
  end
end
