require 'rails_helper'

RSpec.describe OpenAPIEndpoint do
  describe '#uid' do
    it 'returns the path' do
      endpoint = described_class.new(
        path: '/v3/test/endpoint',
        open_api_definition: { 'summary' => 'Test' },
        api: 'api_entreprise'
      )

      expect(endpoint.uid).to eq('/v3/test/endpoint')
    end
  end

  describe '#title' do
    context 'when summary contains bracket notation' do
      it 'formats title with method in parentheses' do
        endpoint = described_class.new(
          path: '/v3/test/endpoint',
          open_api_definition: { 'summary' => '[Identité] Statut étudiant boursier' },
          api: 'api_particulier'
        )

        expect(endpoint.title).to eq('Statut étudiant boursier (Identité)')
      end

      it 'handles INE notation' do
        endpoint = described_class.new(
          path: '/v3/test/endpoint',
          open_api_definition: { 'summary' => '[INE] Statut étudiant' },
          api: 'api_particulier'
        )

        expect(endpoint.title).to eq('Statut étudiant (INE)')
      end
    end

    context 'when summary has no bracket notation' do
      it 'returns the summary as-is' do
        endpoint = described_class.new(
          path: '/v3/test/endpoint',
          open_api_definition: { 'summary' => 'Simple endpoint title' },
          api: 'api_entreprise'
        )

        expect(endpoint.title).to eq('Simple endpoint title')
      end
    end

    context 'when summary is blank' do
      it 'returns the path' do
        endpoint = described_class.new(
          path: '/v3/test/endpoint',
          open_api_definition: { 'summary' => '' },
          api: 'api_entreprise'
        )

        expect(endpoint.title).to eq('/v3/test/endpoint')
      end

      it 'returns the path when summary is nil' do
        endpoint = described_class.new(
          path: '/v3/test/endpoint',
          open_api_definition: {},
          api: 'api_entreprise'
        )

        expect(endpoint.title).to eq('/v3/test/endpoint')
      end
    end
  end

  describe '.all_for_api' do
    context 'with api_entreprise' do
      it 'returns endpoints from API Entreprise OpenAPI definition' do
        endpoints = described_class.all_for_api('api_entreprise')

        expect(endpoints).to be_an(Array)
        expect(endpoints).not_to be_empty
        expect(endpoints.first).to be_a(described_class)
        expect(endpoints.first.api).to eq('api_entreprise')
      end

      it 'includes INSEE endpoint' do
        endpoints = described_class.all_for_api('api_entreprise')
        insee_endpoint = endpoints.find { |e| e.path.include?('insee/sirene/unites_legales') }

        expect(insee_endpoint).to be_present
      end
    end

    context 'with api_particulier' do
      it 'returns endpoints from API Particulier OpenAPI definition' do
        endpoints = described_class.all_for_api('api_particulier')

        expect(endpoints).to be_an(Array)
        expect(endpoints).not_to be_empty
        expect(endpoints.first.api).to eq('api_particulier')
      end

      it 'includes both identite and INE endpoints for CNOUS' do
        endpoints = described_class.all_for_api('api_particulier')
        cnous_endpoints = endpoints.select { |e| e.path.include?('cnous') }

        expect(cnous_endpoints.map(&:path)).to include(
          '/v3/cnous/etudiant_boursier/identite',
          '/v3/cnous/etudiant_boursier/ine'
        )
      end

      it 'filters out france_connect endpoints' do
        endpoints = described_class.all_for_api('api_particulier')
        france_connect_endpoints = endpoints.select { |e| e.path.include?('france_connect') }

        expect(france_connect_endpoints).to be_empty
      end
    end

    context 'with unknown API' do
      it 'returns empty array' do
        endpoints = described_class.all_for_api('unknown_api')

        expect(endpoints).to eq([])
      end
    end

    it 'returns endpoints sorted by title' do
      endpoints = described_class.all_for_api('api_particulier')
      titles = endpoints.map(&:title)

      expect(titles).to eq(titles.sort)
    end

    it 'only includes endpoints with GET method' do
      endpoints = described_class.all_for_api('api_entreprise')

      endpoints.each do |endpoint|
        expect(endpoint.open_api_definition).to be_present
      end
    end
  end
end
