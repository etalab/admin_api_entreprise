require 'rails_helper'

describe JwtUser, type: :jwt do
  # TODO refactor this : initialize JwtUser instance by passing entire JWT payload
  # Extract the payload from a generated session JWT (look below)
  describe '#admin?' do
    it 'returns true for an admin' do
      jwt_user = JwtUser.new(AuthenticationHelper::ADMIN_UID, nil)
      expect(jwt_user).to be_admin
    end

    it 'returns false for a client user' do
      user = UsersFactory.confirmed_user
      jwt_user = JwtUser.new(user.id, nil)
      expect(jwt_user).to_not be_admin
    end
  end

  describe '#manage_token?' do
    let(:token_payload) do
      # call JWTF the way Doorkeeper does
      token = JWTF.generate(resource_owner_id: user.id)
      token_payload = extract_payload_from(token)
      token_payload
    end

    context 'when user is allowed to manage tokens' do
      let(:user) { create(:user_with_roles) }

      it 'returns true' do
        jwt_user = JwtUser.new(token_payload[:uid], token_payload[:grants])

        expect(jwt_user.manage_token?).to eq(true)
      end
    end

    context 'when user is not allowed to manage tokens' do
      let(:user) { create(:user) }

      it 'returns true' do
        jwt_user = JwtUser.new(token_payload[:uid], token_payload[:grants])

        expect(jwt_user.manage_token?).to eq(false)
      end
    end
  end
end
