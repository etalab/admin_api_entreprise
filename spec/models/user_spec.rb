require 'rails_helper'

describe User do
  let(:user) { create :user, :with_jwt }

  describe 'db_columns' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:oauth_api_gouv_id).of_type(:integer) }
    it { is_expected.to have_db_column(:context).of_type(:string) }
    it { is_expected.to have_db_column(:password_digest).of_type(:string) }
    it { is_expected.to have_db_column(:cgu_agreement_date).of_type(:datetime) }
    it { is_expected.to have_db_column(:note).of_type(:text).with_options(default: '') }
    it { is_expected.to have_db_column(:pwd_renewal_token).of_type(:string).with_options(default: nil) }
    it { is_expected.to have_db_column(:admin).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:tokens_newly_transfered).of_type(:boolean).with_options(default: false) }
  end

  describe 'relationships' do
    it { is_expected.to have_many(:jwt_api_entreprise).dependent(:nullify) }
    it { is_expected.to have_many(:contacts).through(:jwt_api_entreprise) }
  end

  describe '#generate_pwd_renewal_token' do
    it 'generates a random string for pwd_renewal_token attribute' do
      user.update(pwd_renewal_token: nil)
      user.generate_pwd_renewal_token
      user.reload

      expect(user.pwd_renewal_token).to match(/\A[0-9a-f]{20}\z/)
    end
  end

  describe '#confirmed?' do
    subject { user.confirmed? }

    context 'when the user has an API Gouv ID' do
      before { user.oauth_api_gouv_id = 12 }
      it { is_expected.to eq(true) }
    end

    context 'when the user does not have an API Gouv ID' do
      before { user.oauth_api_gouv_id = nil }
      it { is_expected.to eq(false) }
    end
  end
end
