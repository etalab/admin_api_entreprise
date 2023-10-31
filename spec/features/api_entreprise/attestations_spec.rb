require 'rails_helper'

RSpec.describe 'User attestations through tokens', app: :api_entreprise do
  include_context 'with siade payloads'

  before do
    login_as(user)

    visit attestations_path
  end

  describe 'token selection menu' do
    subject(:visit_attestations) { visit attestations_path }

    context 'when user has no token with attestation scopes' do
      let(:user) { create(:user) }

      it 'redirect to profile' do
        expect(page).to have_current_path(user_profile_path)
      end
    end

    context 'when user has tokens with attestation scopes' do
      let(:user) { create(:user, :with_token, scopes: %w[attestations_sociales attestations_fiscales], tokens_amount: 2) }
      let(:id_selected_token) { find('select#token').value }
      let(:scopes_selected_token) { Token.find(id_selected_token).scopes }

      it 'has a select list' do
        expect(page).to have_select('token')
      end

      it 'automatically select token with the most permissions' do
        expect(scopes_selected_token.count).to eq(2)
      end

      it 'has 2 options, which are tokens linked to api entreprise' do
        expect(page.all('select#token option').count).to eq(2)
      end
    end
  end

  describe 'search', :js do
    subject(:search) do
      select(token_intitule, from: 'token')
      fill_in('search_siren', with: siren)
      click_button('search')
    end

    let(:token_intitule) { user.tokens.first.intitule }
    let(:facade_double) { instance_double(EntrepriseWithAttestationsFacade, retrieve_company: nil, retrieve_attestation_sociale: nil, retrieve_attestation_fiscale: nil) }
    let(:entreprise) { Entreprise.new(JSON.parse(payload_entreprise)['data'].slice(*entreprise_interesting_fields)) }
    let(:entreprise_interesting_fields) { %w[personne_morale_attributs activite_principale forme_juridique categorie_entreprise] }
    let(:user) { create(:user, :with_token, scopes: ['attestations_fiscales']) }
    let(:siren) { siren_valid }
    let(:with_attestation_sociale) { false }

    before do
      allow(EntrepriseWithAttestationsFacade).to receive(:new).and_return(facade_double)

      allow(facade_double).to receive_messages(
        entreprise:,
        entreprise_raison_sociale: 'raison_sociale',
        entreprise_forme_juridique_libelle: 'forme_juridique_libelle',
        categorie_entreprise: 'categorie_entreprise',
        entreprise_naf_full: 'whatever',
        attestation_fiscale_url: 'attestation-fiscale-url',
        attestation_sociale_url: 'attestation-sociale-url',
        with_attestation_fiscale?: true,
        with_attestation_sociale?: with_attestation_sociale
      )
    end

    context 'when user search a valid siren which works for all endpoints' do
      before do
        search
      end

      it 'shows company name' do
        expect(page).to have_content('raison_sociale')
      end

      context 'when selected token has one attestation scope' do
        it 'shows link to download this attestation only, not the other' do
          expect(page).not_to have_link('attestation-sociale-download')
          expect(page).to have_link('attestation-fiscale-download', href: 'attestation-fiscale-url')
        end
      end

      context 'when selected token have two attestation scopes' do
        let(:user) do
          create(:user, :with_token, scopes: %w[attestations_sociales attestations_fiscales])
        end
        let(:with_attestation_sociale) { true }

        it 'shows both links to download attestations' do
          expect(page).to have_link('attestation-sociale-download', href: 'attestation-sociale-url')
          expect(page).to have_link('attestation-fiscale-download', href: 'attestation-fiscale-url')
        end
      end
    end

    context 'when user search an invalid siren' do
      before do
        allow(facade_double).to receive(:retrieve_company).and_raise(SiadeClientError.new(422, '422 Unprocessable Entity'))
        search
      end

      it 'fails with invalid message' do
        expect(page).to have_css('#error-422')
      end
    end

    context 'when user search a siren not found' do
      before do
        allow(facade_double).to receive(:retrieve_company).and_raise(SiadeClientError.new(404, '404 Not Found'))
        search
      end

      it 'fails with not found message' do
        expect(page).to have_css('#error-404')
      end
    end

    context 'when user choose a token which is unauthorized' do
      before do
        allow(facade_double).to receive(:retrieve_company).and_raise(SiadeClientError.new(401, '401 Unauthorized'))

        search
      end

      it 'fails with invalid message' do
        expect(page).to have_css('#error-401')
      end
    end

    context 'when siren errors on attestation sociale' do
      before do
        allow(facade_double).to receive(:retrieve_attestation_sociale).and_raise(SiadeClientError.new(401, '401 Unauthorized'))

        search
      end

      it 'allows to download attestation fiscale' do
        expect(page).to have_link('attestation-fiscale-download', href: 'attestation-fiscale-url')
      end

      it 'shows error' do
        expect(page).to have_css('#error-401')
      end

      it 'does\'nt allow to download attestation sociale' do
        expect(page).not_to have_link('attestation-sociale-download')
      end
    end
  end
end
