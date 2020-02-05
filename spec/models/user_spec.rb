require 'rails_helper'

describe User do
  let(:user) { create :user, :with_jwt }

  describe 'db_columns' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:context).of_type(:string) }
    it { is_expected.to have_db_column(:password_digest).of_type(:string) }
    it { is_expected.to have_db_column(:confirmation_token).of_type(:string) }
    it { is_expected.to have_db_column(:confirmed_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:confirmation_sent_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:cgu_agreement_date).of_type(:datetime) }
    it { is_expected.to have_db_column(:note).of_type(:text).with_options(default: '') }
    it { is_expected.to have_db_column(:pwd_renewal_token).of_type(:string).with_options(default: nil) }
  end

  describe 'relationships' do
    it { is_expected.to have_many(:jwt_api_entreprise).dependent(:nullify) }
  end

  describe '#generate_pwd_renewal_token' do
    it 'generates a random string for pwd_renewal_token attribute' do
      user.update(pwd_renewal_token: nil)
      user.generate_pwd_renewal_token
      user.reload

      expect(user.pwd_renewal_token).to match(/\A[0-9a-f]{20}\z/)
    end
  end

  describe '#generate_confirmation_token' do
    it 'generates a random string for confirmation_token attribute' do
      user.update(confirmation_token: nil)
      user.generate_confirmation_token
      user.reload

      expect(user.confirmation_token).to match(/\A[0-9a-f]{20}\z/)
    end
  end

  describe '#encoded_jwt' do
    it 'returns an array of all user\'s jwt' do
      expect(user.encoded_jwt.size).to eq(user.jwt_api_entreprise.size)
    end

    context 'when one token is blacklisted' do
      let!(:blacklisted_jwt) { create(:jwt_api_entreprise, :blacklisted, user: user) }

      it 'does not return blacklisted token with #encoded_jwt' do
        expect(user.encoded_jwt).not_to include blacklisted_jwt.rehash
        expect(user.encoded_jwt.size).to eq (user.jwt_api_entreprise.size - 1)
      end
    end

    context 'when one token is archived' do
      let!(:archived_jwt) { create(:jwt_api_entreprise, :archived, user: user) }

      it 'does not return blacklisted token with #encoded_jwt' do
        expect(user.encoded_jwt).not_to include archived_jwt.rehash
        expect(user.encoded_jwt.size).to eq (user.jwt_api_entreprise.size - 1)
      end
    end

    context 'JWT generation' do
      before { expect_any_instance_of(JwtApiEntreprise).to receive(:rehash).and_return('Much token') }

      # TODO learn how to stub this
      pending 'is delegated to the Role#rehash method'
    end
  end
end
