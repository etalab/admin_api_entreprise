require 'rails_helper'

RSpec.describe TokensAssociatedToEmailQuery do
  subject { described_class.new(email:, api:).call }

  let(:email) { 'client@gouv.fr' }
  let(:api) { nil }

  let(:token_list) { Token.where(id: tokens.map(&:id)) }
  let(:token_list_particulier) { token_list.active_for(:particulier) }
  let(:token_list_entreprise) { token_list.active_for(:entreprise) }

  context 'when email is not provided' do
    let(:email) { nil }

    it { is_expected.to be_empty }
  end

  context 'when email is provided from a contact' do
    context 'with tokens' do
      let!(:contact) { create(:user, :contact_technique) }

      let(:tokens) { contact.tokens.to_a }

      context 'when API is not provided' do
        it { is_expected.to match_array(token_list) }
      end

      context 'when API Particulier' do
        let(:api) { :particulier }

        it { is_expected.to match_array(token_list_particulier) }
      end

      context 'when API Entreprise' do
        let(:api) { :entreprise }

        it { is_expected.to match_array(token_list_entreprise) }
      end
    end

    context 'without tokens' do
      let!(:contact) { create(:user, email:) }

      it { is_expected.to be_empty }
    end
  end

  context 'when email is provided from a user' do
    context 'with tokens' do
      let!(:user) { create(:user, :with_token, email:, tokens_amount: 2) }

      let(:tokens) { user.tokens.to_a }

      context 'when API is not provided' do
        it { is_expected.to match_array(token_list) }
      end

      context 'when API Particulier' do
        let(:api) { :particulier }

        it { is_expected.to match_array(token_list_particulier) }
      end

      context 'when API Entreprise' do
        let(:api) { :entreprise }

        it { is_expected.to match_array(token_list_entreprise) }
      end
    end

    context 'without tokens' do
      let!(:user) { create(:user, email:) }

      it { is_expected.to be_empty }
    end
  end

  context 'when email is from a user demandeur and contact' do
    context 'with tokens' do
      let!(:contact) do
        create(:user,
          :with_roles,
          email:,
          roles: %w[demandeur contact_technique])
      end
      let(:tokens) { contact.tokens.to_a }

      context 'when API is not provided' do
        it { is_expected.to match_array(token_list) }
      end

      context 'when API Particulier' do
        let(:api) { :particulier }

        it { is_expected.to match_array(token_list_particulier) }
      end

      context 'when API Entreprise' do
        let(:api) { :entreprise }

        it { is_expected.to match_array(token_list_entreprise) }
      end
    end

    context 'without tokens' do
      let!(:user) { create(:user, email:) }

      it { is_expected.to be_empty }
    end
  end
end
