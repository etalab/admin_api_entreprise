RSpec.shared_context 'admin request' do
  before do
    set_admin_token
  end
end

RSpec.shared_context 'user request' do
  before do
    user = UsersFactory.confirmed_user
    set_user_token(user.id)
  end
end
