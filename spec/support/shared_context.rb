RSpec.shared_context('admin request') do
  before do
    fill_request_headers_with_admin_jwt
  end
end

RSpec.shared_context('user request') do
  before do
    user = create(:user)
    fill_request_headers_with_user_jwt(user.id)
  end
end

RSpec.shared_context('oauth api gouv fresh token') do
  # Time when the recorded ID Token hasn't expired yet
  let(:id_token_alive_time) { Time.at(1589460000) }

  before { Timecop.freeze(id_token_alive_time) }

  after { Timecop.return }
end
