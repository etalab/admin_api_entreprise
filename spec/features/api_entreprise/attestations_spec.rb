require 'rails_helper'

RSpec.describe 'User attestations through tokens', app: :api_entreprise do
  include_context 'with siade payloads'

  let(:inactive_token_intitule) { 'Token with another scope' }
  let(:another_api_entreprise_scope) { create(:scope, name: 'whatever', code: 'whatever', api: 'entreprise') }
  let!(:inactive_token) { create(:token, user:, scopes: [another_api_entreprise_scope], intitule: inactive_token_intitule) }

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
      let(:user) { create(:user, :with_token, scopes: %w[attestations_sociales attestations_fiscales]) }
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

  describe 'search', js: true do
    subject(:search) do
      select(token, from: 'token')
      fill_in('search_siren', with: siren)
      click_button('search')
    end

    before do
      allow(EntrepriseWithAttestationsFacade).to receive(:new).and_return(facade_double)

      allow(facade_double).to receive(:entreprise).and_return(entreprise)
      allow(facade_double).to receive(:entreprise_raison_sociale).and_return(entreprise.raison_sociale)
      allow(facade_double).to receive(:entreprise_forme_juridique).and_return(entreprise.forme_juridique)
      allow(facade_double).to receive(:categorie_entreprise).and_return(entreprise.categorie_entreprise)
      allow(facade_double).to receive(:entreprise_naf_full).and_return('whatever')

      allow(facade_double).to receive(:attestation_fiscale_url).and_return(payload_attestation_fiscale['url'])
      allow(facade_double).to receive(:attestation_sociale_url).and_return(payload_attestation_sociale['url'])
    end

    let(:facade_double) { instance_double(EntrepriseWithAttestationsFacade, retrieve_company: nil, retrieve_attestation_sociale: nil, retrieve_attestation_fiscale: nil) }
    let(:entreprise) { Entreprise.new(payload_entreprise['entreprise']) }
    let(:user) { create(:user, :with_token, scopes: ['attestations_fiscales']) }
    let(:siren) { siren_valid }

    context 'when user search a valid siren which works for all endpoints' do
      let(:token) { 'Token with scopes: ["attestations_fiscales"]' }

      before do
        search
      end

      it 'shows company name' do
        expect(page).to have_content('dummy name')
      end

      context 'when selected token have no attestation scopes' do
        let(:token) { inactive_token_intitule }

        it 'doesnt show attestations download links' do
          expect(page).not_to have_link('attestation-sociale-download')
          expect(page).not_to have_link('attestation-fiscale-download')
        end
      end

      context 'when selected token has one attestation scope' do
        let(:token) { 'Token with scopes: ["attestations_fiscales"]' }

        it 'shows link to download this attestation only, not the other' do
          expect(page).not_to have_link('attestation-sociale-download')
          expect(page).to have_link('attestation-fiscale-download',
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
        end
      end

      context 'when selected token have two attestation scopes' do
        let(:user) do
          create(:user, :with_token, scopes: %w[attestations_sociales attestations_fiscales])
        end

        let(:token) { 'Token with scopes: ["attestations_sociales", "attestations_fiscales"]' }

        it 'shows both links to download attestations' do
          expect(page).to have_link('attestation-sociale-download',
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_sociale.pdf')
          expect(page).to have_link('attestation-fiscale-download',
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
        end
      end
    end

    context 'when user search an invalid siren' do
      let(:token) { inactive_token_intitule }

      before do
        allow(facade_double).to receive(:retrieve_company).and_raise(SiadeClientError.new(422, '422 Unprocessable Entity'))
        search
      end

      it 'fails with invalid message' do
        expect(page).to have_css('#error-422')
      end
    end

    context 'when user search a siren not found' do
      let(:token) { inactive_token_intitule }

      before do
        allow(facade_double).to receive(:retrieve_company).and_raise(SiadeClientError.new(404, '404 Not Found'))
        search
      end

      it 'fails with not found message' do
        expect(page).to have_css('#error-404')
      end
    end

    context 'when user choose a token which is unauthorized' do
      let(:token) { inactive_token_intitule }

      before do
        allow(facade_double).to receive(:retrieve_company).and_raise(SiadeClientError.new(401, '401 Unauthorized'))

        search
      end

      it 'fails with invalid message' do
        expect(page).to have_css('#error-401')
      end
    end

    context 'when siren errors on attestation sociale' do
      let(:token) { 'Token with scopes: ["attestations_fiscales"]' }

      before do
        allow(facade_double).to receive(:retrieve_attestation_sociale).and_raise(SiadeClientError.new(401, '401 Unauthorized'))

        search
      end

      it 'allows to download attestation fiscale' do
        expect(page).to have_link('attestation-fiscale-download',
          href: 'http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
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
