RSpec.describe INSEESireneAPIClient do
  let(:insee_api_authentication) { instance_double(INSEEAPIAuthentication, access_token: 'access_token') }

  before do
    allow(INSEEAPIAuthentication).to receive(:new).and_return(insee_api_authentication)
  end

  describe '#etablissement' do
    subject(:etablissement_payload) { described_class.new.etablissement(siret:) }

    let(:siret) { '13002526500013' }

    context 'when the API returns a 200' do
      let(:valid_payload) { insee_sirene_api_etablissement_valid_payload(siret:) }

      before do
        stub_request(:get, "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}").to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: valid_payload.to_json
        )
      end

      it 'renders a valid json from payload' do
        expect(etablissement_payload).to eq(valid_payload)
      end
    end

    context 'when API returns something else than 200' do
      before do
        stub_request(:get, "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}").to_return(
          status: 500,
          headers: { 'Content-Type' => 'application/json' },
          body: ''
        )
      end

      it 'raises an error' do
        expect { etablissement_payload }.to raise_error(Faraday::Error)
      end
    end
  end
end
