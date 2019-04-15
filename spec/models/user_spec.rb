require 'rails_helper'

describe User do
  let(:user) { create :user, :with_jwt }

  describe 'db_columns' do
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:context).of_type(:string) }
    it { is_expected.to have_db_column(:password_digest).of_type(:string) }
    it { is_expected.to have_db_column(:confirmation_token).of_type(:string) }
    it { is_expected.to have_db_column(:confirmed_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:confirmation_sent_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:allow_token_creation).of_type(:boolean) }
    it { is_expected.to have_db_column(:cgu_agreement_date).of_type(:datetime) }
    it { is_expected.to have_db_column(:note).of_type(:text) }
  end

  describe 'relationships' do
    it { is_expected.to have_many(:contacts).dependent(:destroy) }
    it { is_expected.to have_and_belong_to_many :roles }
    it { is_expected.to have_many :jwt_api_entreprise }
  end

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

  describe '#allowed_roles' do
    let(:role1) { create(:role, code: 'rol1') }
    let(:role2) { create(:role, code: 'rol2') }
    let(:user) { create(:user) }
    subject { Set.new(user.allowed_roles) } # use Set structure for array comparison

    context 'when user is allowed to create tokens' do
      it 'returns given roles code' do
        user.allow_token_creation = true
        user.roles << [role1, role2]
        user.save

        expect(subject).to eq(Set.new(['rol1', 'rol2']))
      end
    end

    context 'when user is not allowed to create tokens' do
      it 'returns linked token roles code without duplicates' do
        token1 = token2 = create(:token_without_roles)
        token1.roles << role1
        token2.roles << [role1, role2]
        user.jwt_api_entreprise << [token1, token2]

        expect(subject).to eq(Set.new(['rol1', 'rol2']))
      end
    end
  end
end
