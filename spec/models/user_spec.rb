require 'rails_helper'

describe User do
  let(:user) { create(:user_with_jwt) }

  describe '#encoded_jwt' do
    it 'returns an array of all user\'s jwt' do
      expect(user.encoded_jwt.size).to eq(user.jwt_api_entreprise.size)
    end

    context 'JWT generation' do
      before { expect_any_instance_of(JwtApiEntreprise).to receive(:rehash).and_return('Much token') }

      # TODO learn how to stub this
      pending 'is delegated to the Role#rehash method'
    end
  end

  describe '#manage_token?' do
    it 'returns false when user is not allowed to create tokens' do
      user = create(:user)

      expect(user.manage_token?).to eq(false)
    end

    it 'returns true when user is allowed to create tokens' do
      user = create(:user_with_roles)

      expect(user.manage_token?).to eq(true)
    end
  end
end
