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
end
