require 'rails_helper'

RSpec.describe 'Download attestations', app: :api_entreprise do
  before do
    login_as(user)
  end

  describe 'token selection menu' do
    context 'when user has no token with attestation scopes' do
      let(:user) { create(:user) }

      it 'redirect to profile' do
        visit attestations_path

        expect(page).to have_current_path(user_profile_path)
      end
    end

    context 'when user has tokens with attestation scopes' do
      let(:user) { create(:user) }
      let(:authorization_request) { create(:authorization_request, :with_demandeur, demandeur: user) }
      let!(:valid_token) { create(:token, authorization_request:, scopes: %w[attestations_sociales]) }
      let!(:most_interesting_token) { create(:token, authorization_request:, scopes: %w[attestations_sociales attestations_fiscales]) }
      let!(:invalid_token) do
        another_authorization_request = create(:authorization_request, :with_demandeur, api: 'particulier', demandeur: user)
        create(:token, authorization_request: another_authorization_request)
      end

      it 'has a select list' do
        visit attestations_path

        expect(page).to have_select('token')
      end

      it 'selects the token with most scopes' do
        visit attestations_path

        expect(find('select#token').value).to eq(most_interesting_token.id.to_s)
      end

      it 'has 2 options, which are tokens linked to api entreprise' do
        visit attestations_path

        token_options = page.all('select#token option')

        expect(token_options.count).to eq(2)
        expect(token_options.pluck(:value)).to contain_exactly(most_interesting_token.id, valid_token.id)
      end
    end
  end

  describe 'search' do
    subject(:search) do
      visit attestations_path

      select(selected_token.intitule, from: 'token')

      fill_in('search_siren', with: siren)

      click_button('search')
    end

    let(:user) { create(:user, :with_token, tokens_amount: 2, scopes: ['attestations_fiscales']) }
    let(:selected_token) { user.tokens.first }
    let(:facade_double) { instance_double(EntrepriseWithAttestationsFacade) }
    let(:siren) { siren_valid }
    let(:entreprise) { build(:entreprise) }

    before do
      allow(EntrepriseWithAttestationsFacade).to receive(:new).and_return(facade_double)

      allow(facade_double).to receive_messages(
        perform: true,
        success?: success,
        error: 'Some error',
        entreprise:,
        attestation_fiscale_url: 'https://attestation-fiscale.com/file.pdf',
        attestation_sociale_url: nil
      )
    end

    context 'when it succeeds' do
      let(:success) { true }

      it 'calls facade with valid attributes' do
        expect(EntrepriseWithAttestationsFacade).to receive(:new).with(
          token: selected_token,
          siren:
        )

        search
      end

      it 'shows company name with valid link to download attestations' do
        search

        expect(page).to have_content(entreprise.raison_sociale)
        expect(page).not_to have_link('attestation-sociale-download')
        expect(page).to have_link('attestation-fiscale-download', href: 'https://attestation-fiscale.com/file.pdf')
      end
    end

    context 'when it fails' do
      let(:success) { false }

      it 'shows error message and no company data' do
        search

        expect(page).to have_content('Some error')

        expect(page).not_to have_content(entreprise.raison_sociale)
        expect(page).not_to have_link('attestation-sociale-download')
        expect(page).not_to have_link('attestation-fiscale-download')
      end
    end
  end
end
