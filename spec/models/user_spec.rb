require 'rails_helper'

RSpec.describe User do
  let(:user) { create :user, :with_jwt }

  describe 'db_columns' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:oauth_api_gouv_id).of_type(:string) }
    it { is_expected.to have_db_column(:context).of_type(:string) }
    it { is_expected.to have_db_column(:cgu_agreement_date).of_type(:datetime) }
    it { is_expected.to have_db_column(:note).of_type(:text).with_options(default: '') }
    it { is_expected.to have_db_column(:pwd_renewal_token).of_type(:string).with_options(default: nil) }
    it { is_expected.to have_db_column(:admin).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:tokens_newly_transfered).of_type(:boolean).with_options(default: false) }
  end

  describe 'db_indexes' do
    it { is_expected.to have_db_index(:created_at) }
  end

  describe 'relationships' do
    it { is_expected.to have_many(:jwt_api_entreprise) }
    it { is_expected.to have_many(:roles).through(:jwt_api_entreprise) }
    it { is_expected.to have_many(:contacts) }
  end

  describe '.added_since_yesterday' do
    subject { described_class }

    let!(:user) { create(:user, added_datetime) }

    context 'when he has just been created ' do
      let(:added_datetime) { :added_since_yesterday }

      its(:added_since_yesterday) { is_expected.to be_exist user.id }
    end

    context 'when he was created a long time ago' do
      let(:added_datetime) { :not_added_since_yesterday }

      its(:added_since_yesterday) { is_expected.not_to be_exist user.id }
    end
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
      before { user.oauth_api_gouv_id = '12' }
      it { is_expected.to eq(true) }
    end

    context 'when the user does not have an API Gouv ID' do
      before { user.oauth_api_gouv_id = nil }
      it { is_expected.to eq(false) }
    end
  end

  describe 'saving callbacks' do
    it 'downcase emails before saving' do
      user = create :user, email: 'CAPS_LOCK@EMAIL.COM'
      expect(user.email).to eq('caps_lock@email.com')
    end
  end
end
