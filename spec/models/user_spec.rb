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
    it { is_expected.to have_db_column(:note).of_type(:text) }
  end

  describe 'relationships' do
    it { is_expected.to have_many(:contacts).dependent(:destroy) }
    it { is_expected.to have_many :jwt_api_entreprise }
  end

  describe '#encoded_jwt' do
    it 'returns an array of all user\'s jwt' do
      expect(user.encoded_jwt.size).to eq(user.jwt_api_entreprise.size)
    end

    context 'when one token is blacklisted' do
      let!(:blacklisted_jwt) do
        user
          .jwt_api_entreprise
          .first
          .tap { |jwt| jwt.update(blacklisted: true) }
      end

      it 'does not return blacklisted token with #encoded_jwt' do
        expect(user.encoded_jwt).to_not include blacklisted_jwt.rehash
        expect(user.encoded_jwt.size).to eq(user.jwt_api_entreprise.size - 1)
      end

      it 'returns one #blacklisted_jwt' do
        expect(user.blacklisted_jwt).to eq [blacklisted_jwt.rehash]
      end
    end

    context 'JWT generation' do
      before { expect_any_instance_of(JwtApiEntreprise).to receive(:rehash).and_return('Much token') }

      # TODO: learn how to stub this
      pending 'is delegated to the Role#rehash method'
    end
  end
end
