# frozen_string_literal: true

RSpec.describe 'Stubbing repos' do
  before do
    allow(Repos::User).to receive(:find).and_return(nil)
  end

  it 'does something' do
    expect(true).to be(true)
  end
end
