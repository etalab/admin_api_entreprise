RSpec.shared_context 'admin request' do
  before do
    fill_request_headers_with_admin_jwt
  end
end

RSpec.shared_context 'user request' do
  before do
    user = create(:confirmed_user)
    fill_request_headers_with_user_jwt(user.id)
  end
end
