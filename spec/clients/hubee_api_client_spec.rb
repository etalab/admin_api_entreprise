RSpec.describe HubEEAPIClient do
  let(:hubee_api_authentication) { instance_double(HubEEAPIAuthentication, access_token: 'access_token') }

  before do
    allow(HubEEAPIAuthentication).to receive(:new).and_return(hubee_api_authentication)
  end

  describe '#find_organization' do
    subject(:find_organization_payload) { described_class.new.find_organization(organization) }

    let(:organization) { Organization.new(siret) }
    let(:siret) { '13002526500013' }
    let(:code_commune) { '13055' }
    let(:host) { Rails.application.credentials.hubee_api_url }

    before do
      allow(organization).to receive(:code_commune_etablissement).and_return(code_commune)
    end

    context 'when the API returns a 200' do
      let(:valid_payload) { hubee_organization_payload(siret:, code_commune:) }

      before do
        stub_request(:get, "#{host}/referential/v1/organizations/SI-#{siret}-#{code_commune}").to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: valid_payload.to_json
        )
      end

      it 'renders a valid json from payload' do
        expect(find_organization_payload).to eq(valid_payload)
      end
    end

    context 'when API returns 404' do
      before do
        stub_request(:get, "#{host}/referential/v1/organizations/SI-#{siret}-#{code_commune}").to_return(
          status: 404,
          headers: { 'Content-Type' => 'application/json' },
          body: {
            'header' => {
              'statut' => 404,
              'message' => "Aucun élément trouvé pour le siret #{siret}"
            }
          }.to_json
        )
      end

      it 'raises a NotFound error' do
        expect { find_organization_payload }.to raise_error(HubEEAPIClient::NotFound)
      end
    end

    context 'when API returns unknown status' do
      before do
        stub_request(:get, "#{host}/referential/v1/organizations/SI-#{siret}-#{code_commune}").to_return(
          status: 500
        )
      end

      it 'raises an error' do
        expect { find_organization_payload }.to raise_error(Faraday::Error)
      end
    end
  end
end
