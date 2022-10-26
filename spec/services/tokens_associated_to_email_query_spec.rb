require 'rails_helper'

RSpec.describe TokensAssociatedToEmailQuery do
  subject { described_class.new(email:, api:).call }

  let(:email) { 'client@gouv.fr' }
  let(:api) { nil }

  let(:token_list) { Token.where(id: tokens.map(&:id)) }
  let(:token_list_particulier) { token_list.valid_for(:particulier) }
  let(:token_list_entreprise) { token_list.valid_for(:entreprise) }

  context 'when email is not provided' do
    let(:email) { nil }

    it { is_expected.to eq(Token.none) }
  end

  context 'when email is provided from a contact' do
    context 'with tokens' do
      let!(:contact_1) { create(:contact, email:, token: create(:token)) }
      let!(:contact_2) { create(:contact, email:, token: create(:token)) }

      let(:tokens) { [contact_1.token, contact_2.token] }

      context 'when API is not provided' do
        it { is_expected.to contain_exactly(*token_list) }
      end

      context 'when API Particulier' do
        let(:api) { :particulier }

        it { is_expected.to contain_exactly(*token_list_particulier) }
      end

      context 'when API Entreprise' do
        let(:api) { :entreprise }

        it { is_expected.to contain_exactly(*token_list_particulier) }
      end
    end

    context 'without tokens' do
      let!(:contact_1) { create(:contact, email:) }
      let!(:contact_2) { create(:contact, email:) }

      it { is_expected.to eq(Token.none) }
    end
  end

  context 'when email is provided from a user' do
    context 'with tokens' do
      let!(:user) { create(:user, :with_token, email:, tokens_amount: 2) }

      let(:tokens) { user.tokens.to_a }

      context 'when API is not provided' do
        it { is_expected.to contain_exactly(*token_list) }
      end

      context 'when API Particulier' do
        let(:api) { :particulier }

        it { is_expected.to contain_exactly(*token_list_particulier) }
      end

      context 'when API Entreprise' do
        let(:api) { :entreprise }

        it { is_expected.to contain_exactly(*token_list_entreprise) }
      end
    end

    context 'without tokens' do
      let!(:user) { create(:user, email:) }

      it { is_expected.to eq(Token.none) }
    end
  end

  context 'when email is from both user and contact' do
    context 'with tokens' do
      let!(:user) { create(:user, :with_token, email:, tokens_amount: 2) }
      let!(:contact) { create(:contact, email:, token: create(:token)) }
      let(:tokens) { user.tokens.to_a + [contact.token] }

      context 'when API is not provided' do
        it { is_expected.to contain_exactly(*token_list) }
      end

      context 'when API Particulier' do
        let(:api) { :particulier }

        it { is_expected.to contain_exactly(*token_list_particulier) }
      end

      context 'when API Entreprise' do
        let(:api) { :entreprise }

        it { is_expected.to contain_exactly(*token_list_entreprise) }
      end
    end

    context 'without tokens' do
      let!(:user) { create(:user, email:) }
      let!(:contact) { create(:contact, email:) }

      it { is_expected.to eq(Token.none) }
    end
  end
end
