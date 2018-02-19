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
end
