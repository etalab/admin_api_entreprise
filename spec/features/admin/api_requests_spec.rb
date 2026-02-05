require 'rails_helper'

RSpec.describe 'Admin: API requests' do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  context 'when using API Entreprise', app: :api_entreprise do
    let(:siade_entreprise_url) { APIEntreprise::BASE_URL }

    describe 'visiting the API requests page' do
      it 'displays the API requests form with endpoint selector' do
        visit admin_api_requests_path

        expect(page).to have_content('Requêtes API')
        expect(page).to have_select('endpoint_uid')
        expect(page).to have_no_select('api')
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

    describe 'parameter labels' do
      it 'displays technical field name as label' do
        visit admin_api_requests_path(endpoint_uid: '/v3/insee/sirene/unites_legales/{siren}')

        expect(page).to have_field('siren')
        expect(page).to have_content('siren')
      end
    end
  end

  context 'when using API Particulier', app: :api_particulier do
    let(:siade_particulier_url) { APIParticulier::BASE_URL }

    def valid_api_particulier_request?(req)
      query = Rack::Utils.parse_nested_query(req.uri.query)
      query['prenoms'] == ['Jean'] && query['nomNaissance'] == 'Dupont'
    end

    describe 'making an API Particulier request with array params' do
      let(:response_body) { { data: { quotient_familial: 1500 } }.to_json }

      before do
        stub_request(:get, %r{#{siade_particulier_url}/v3/dss/quotient_familial/identite})
          .to_return(status: 200, body: response_body)
      end

      it 'sends array params properly formatted' do
        visit admin_api_requests_path(endpoint_uid: '/v3/dss/quotient_familial/identite')

        fill_in 'nomNaissance', with: 'Dupont'
        first('input[name="prenoms[]"]').fill_in with: 'Jean'
        fill_in 'anneeDateNaissance', with: '1990'
        fill_in 'moisDateNaissance', with: '01'

        click_on 'Envoyer la requête'

        expect(page).to have_content('200')
        expect(page).to have_content('1500')

        expect(
          a_request(:get, %r{#{siade_particulier_url}/v3/dss/quotient_familial/identite})
            .with { |req| valid_api_particulier_request?(req) }
        ).to have_been_made
      end
    end

    describe 'array fields' do
      it 'displays add button for array parameters' do
        visit admin_api_requests_path(endpoint_uid: '/v3/dss/quotient_familial/identite')

        expect(page).to have_button('+ Ajouter une valeur')
        expect(page).to have_field('prenoms[]')
      end
    end

    describe 'API Particulier UI' do
      it 'displays technical parameter names' do
        visit admin_api_requests_path(endpoint_uid: '/v3/dss/quotient_familial/identite')

        expect(page).to have_field('nomNaissance')
        expect(page).to have_content('nomNaissance')
      end
    end
  end
end
