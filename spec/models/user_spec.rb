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

  describe 'constraints' do
    describe '#email' do
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to allow_value('valid@email.com').for(:email) }
      it { is_expected.not_to allow_value('not an email').for(:email) }
    end
  end

  describe '.added_since_yesterday' do
    subject { described_class }

    let!(:user) { create(:user, added_datetime) }

    context 'when he has just been created' do
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

      it { is_expected.to be(true) }
    end

    context 'when the user does not have an API Gouv ID' do
      before { user.oauth_api_gouv_id = nil }

      it { is_expected.to be(false) }
    end

    context 'when the user has an empty API Gouv ID' do
      before { user.oauth_api_gouv_id = '' }

      it { is_expected.to be(false) }
    end
  end

  describe '#find_or_initialize_by_email' do
    subject { described_class.find_or_initialize_by_email(email) }

    let(:email) { 'email_WITH@case.COM' }

    context 'when email does not exist' do
      its(:id) { is_expected.to be_nil }
      its(:email) { is_expected.to eq email }
    end

    context 'when email already exists' do
      let!(:user) { create :user, email: }

      its(:id) { is_expected.to eq user.id }
      its(:email) { is_expected.to eq email }
    end

    context 'when email already exists with different case' do
      let!(:user) { create :user, email: 'EMAIL_with@CASE.com' }

      its(:id) { is_expected.to eq user.id }
      its(:email) { is_expected.to eq 'EMAIL_with@CASE.com' }
    end
  end

  describe '#any_token_with_attestation_role?' do
    subject { user.any_token_with_attestation_role? }

    context 'when user doesnt have attestation roles' do
      it { is_expected.to be_falsey }
    end

    context 'when user has attestation role' do
      let(:user) { create :user, :with_jwt_specific_roles, specific_roles: ['attestations_fiscales'] }

      it { is_expected.to be_truthy }
    end
  end
end
