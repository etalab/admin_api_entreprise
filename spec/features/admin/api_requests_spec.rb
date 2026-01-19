require 'rails_helper'

def valid_api_particulier_request?(req)
  query = Rack::Utils.parse_nested_query(req.uri.query)
  query['prenoms'] == %w[Jean Pierre] && query['nomNaissance'] == 'Dupont'
end

RSpec.describe 'Admin: API requests', app: :api_entreprise do
  let(:admin) { create(:user, :admin) }
  let(:siade_entreprise_url) { APIEntreprise::BASE_URL }
  let(:siade_particulier_url) { APIParticulier::BASE_URL }

  before do
    login_as(admin)
  end

  describe 'visiting the API requests page' do
    it 'displays the API requests form with all APIs' do
      visit admin_api_requests_path

      expect(page).to have_content('Requêtes API')
      expect(page).to have_select('api', with_options: ['API Entreprise', 'API Particulier'])
      expect(page).to have_select('endpoint_uid')
    end
  end

  describe 'making an API Entreprise request' do
    let(:response_body) { { data: { siren: '130025265' } }.to_json }

    before do
      stub_request(:get, %r{#{siade_entreprise_url}/v3/insee/sirene/unites_legales/130025265})
        .to_return(status: 200, body: response_body)
    end

    it 'substitutes path parameters and calls the correct URL' do
      visit admin_api_requests_path(endpoint_uid: '/v3/insee/sirene/unites_legales/{siren}')

      expect(page).to have_field('siren')
      fill_in 'siren', with: '130025265'
      click_on 'Envoyer la requête'

      expect(page).to have_content('200')
      expect(page).to have_content('130025265')
      expect(a_request(:get, %r{#{siade_entreprise_url}/v3/insee/sirene/unites_legales/130025265})).to have_been_made
    end
  end

  describe 'making an API Particulier request' do
    let(:response_body) { { data: { quotient_familial: 1500 } }.to_json }

    before do
      stub_request(:get, %r{#{siade_particulier_url}/v3/dss/quotient_familial/identite})
        .to_return(status: 200, body: response_body)
    end

    it 'sends query parameters with array params properly formatted' do
      visit admin_api_requests_path(api: 'api_particulier', endpoint_uid: '/v3/dss/quotient_familial/identite')

      fill_in 'nomNaissance', with: 'Dupont'
      fill_in 'prenoms', with: 'Jean Pierre'
      fill_in 'anneeDateNaissance', with: '1990'
      fill_in 'moisDateNaissance', with: '01'
      click_on 'Envoyer la requête'

      expect(page).to have_content('200')
      expect(page).to have_content('1500')
      expect(page).to have_field('prenoms', with: 'Jean Pierre')

      expect(
        a_request(:get, %r{#{siade_particulier_url}/v3/dss/quotient_familial/identite})
          .with { |req| valid_api_particulier_request?(req) }
      ).to have_been_made
    end
  end

  describe 'API Particulier UI' do
    it 'displays endpoints from OpenAPI with humanized parameter names' do
      visit admin_api_requests_path(api: 'api_particulier', endpoint_uid: '/v3/dss/quotient_familial/identite')

      expect(page).to have_field('nomNaissance')
      expect(page).to have_content('Nom naissance')
    end
  end
end
