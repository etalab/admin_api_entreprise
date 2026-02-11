require 'rails_helper'

RSpec.describe APIRequestFacade do
  describe '#api_identifier' do
    it 'returns api_entreprise for entreprise namespace' do
      facade = described_class.new(namespace: 'entreprise')

      expect(facade.api_identifier).to eq('api_entreprise')
    end

    it 'returns api_particulier for particulier namespace' do
      facade = described_class.new(namespace: 'particulier')

      expect(facade.api_identifier).to eq('api_particulier')
    end
  end

  describe '#endpoints' do
    context 'with entreprise namespace' do
      subject(:facade) { described_class.new(namespace: 'entreprise') }

      it 'returns endpoints from API Entreprise OpenAPI definition' do
        expect(facade.endpoints).to be_an(Array)
        expect(facade.endpoints).not_to be_empty
        expect(facade.endpoints.first).to be_a(OpenAPIEndpoint)
        expect(facade.endpoints.first.api).to eq('api_entreprise')
      end

      it 'includes INSEE endpoint' do
        insee_endpoint = facade.endpoints.find { |e| e.path.include?('insee/sirene/unites_legales') }

        expect(insee_endpoint).to be_present
      end

      it 'returns endpoints sorted by title' do
        titles = facade.endpoints.map(&:title)

        expect(titles).to eq(titles.sort)
      end
    end

    context 'with particulier namespace' do
      subject(:facade) { described_class.new(namespace: 'particulier') }

      it 'returns endpoints from API Particulier OpenAPI definition' do
        expect(facade.endpoints).to be_an(Array)
        expect(facade.endpoints).not_to be_empty
        expect(facade.endpoints.first.api).to eq('api_particulier')
      end

      it 'filters out france_connect endpoints' do
        france_connect_endpoints = facade.endpoints.select { |e| e.path.include?('france_connect') }

        expect(france_connect_endpoints).to be_empty
      end
    end

    context 'with unknown namespace' do
      subject(:facade) { described_class.new(namespace: 'unknown') }

      it 'returns empty array' do
        expect(facade.endpoints).to eq([])
      end
    end
  end

  describe '#endpoints_grouped_by_tag' do
    subject(:facade) { described_class.new(namespace: 'entreprise') }

    it 'groups endpoints by OpenAPI tag' do
      grouped = facade.endpoints_grouped_by_tag

      expect(grouped).to be_a(Hash)
      expect(grouped.values.flatten(1)).to all(be_an(Array).and(have_attributes(size: 2)))
    end
  end

  describe '#selected_endpoint' do
    subject(:facade) do
      described_class.new(
        namespace: 'entreprise',
        selected_endpoint_uid: '/v3/insee/sirene/unites_legales/{siren}'
      )
    end

    it 'returns the endpoint matching selected_endpoint_uid' do
      expect(facade.selected_endpoint).to be_present
      expect(facade.selected_endpoint.path).to eq('/v3/insee/sirene/unites_legales/{siren}')
    end

    it 'returns nil when no endpoint selected' do
      facade = described_class.new(namespace: 'entreprise')

      expect(facade.selected_endpoint).to be_nil
    end
  end

  describe '#parameters' do
    context 'with path parameters' do
      subject(:facade) do
        described_class.new(
          namespace: 'entreprise',
          selected_endpoint_uid: '/v3/insee/sirene/unites_legales/{siren}'
        )
      end

      it 'includes path parameters as required' do
        siren_param = facade.parameters.find { |p| p.name == 'siren' }

        expect(siren_param).to be_present
        expect(siren_param.required).to be(true)
        expect(siren_param.location).to eq('path')
      end
    end

    context 'with query parameters' do
      subject(:facade) do
        described_class.new(
          namespace: 'particulier',
          selected_endpoint_uid: '/v3/dss/quotient_familial/identite'
        )
      end

      it 'includes query parameters' do
        params = facade.parameters

        expect(params.any? { |p| p.location == 'query' }).to be(true)
      end

      it 'marks array parameters correctly' do
        prenoms_param = facade.parameters.find { |p| p.name == 'prenoms[]' }

        expect(prenoms_param).to be_present
        expect(prenoms_param.array?).to be(true)
      end

      it 'excludes fixed params (recipient, context, object)' do
        param_names = facade.parameters.map(&:name)

        expect(param_names).not_to include('recipient', 'context', 'object')
      end
    end

    it 'returns empty array when no endpoint selected' do
      facade = described_class.new(namespace: 'entreprise')

      expect(facade.parameters).to eq([])
    end
  end

  describe '#execute_request' do
    subject(:facade) do
      described_class.new(
        namespace: 'entreprise',
        selected_endpoint_uid: '/v3/insee/sirene/unites_legales/{siren}'
      )
    end

    let(:siade_url) { APIEntreprise::BASE_URL }

    before do
      stub_request(:get, %r{#{siade_url}/v3/insee/sirene/unites_legales/130025265})
        .to_return(status: 200, body: { data: { siren: '130025265' } }.to_json)
    end

    it 'calls Siade::ManualRequest with transformed params' do
      result = facade.execute_request(
        'siren' => '130025265',
        'context' => 'Débugging',
        'object' => 'user_1'
      )

      expect(result[:status]).to eq(200)
      expect(JSON.parse(result[:body])['data']['siren']).to eq('130025265')
      expect(result[:request_params]).to eq('siren' => '130025265')
    end

    it 'returns nil when no endpoint selected' do
      facade = described_class.new(namespace: 'entreprise')

      expect(facade.execute_request('siren' => '130025265')).to be_nil
    end
  end
end
