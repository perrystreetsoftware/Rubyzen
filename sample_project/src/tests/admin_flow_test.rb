# frozen_string_literal: true

RSpec.describe 'Admin flow' do
  it 'lists users without admin context' do
    get '/admin/users'
  end

  it 'lists users with admin context' do
    with_admin_context do
      get '/admin/users'
    end
  end
end
