require 'rails_helper'

RSpec.describe Siade::ManualRequest, type: :service do
  let(:siade_entreprise_url) { APIEntreprise::BASE_URL }
  let(:admin_token) { 'test_admin_token' }
  let(:siade_params) do
    {
      context: 'Admin',
      recipient: '13002526500013',
      object: 'Debug requête'
    }
  end
  let(:siade_headers) do
    { Authorization: "Bearer #{admin_token}" }
  end

  before do
    allow(AdminAPIToken).to receive(:for).with('api_entreprise').and_return(admin_token)
  end

  describe '#call' do
    subject { described_class.new(endpoint_path:, params:).call }

    context 'with path parameters' do
      let(:endpoint_path) { '/v3/insee/sirene/unites_legales/{siren}' }
      let(:params) { { 'siren' => '130025265' } }
      let(:endpoint_url) { "#{siade_entreprise_url}/v3/insee/sirene/unites_legales/130025265" }
      let(:response_body) { { data: { siren: '130025265' } }.to_json }

      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: response_body)
      end

      it 'returns body and status' do
        expect(subject).to eq({ body: response_body, status: 200 })
      end
    end

    context 'when API returns an error' do
      let(:endpoint_path) { '/v3/insee/sirene/unites_legales/{siren}' }
      let(:params) { { 'siren' => '000000000' } }
      let(:endpoint_url) { "#{siade_entreprise_url}/v3/insee/sirene/unites_legales/000000000" }
      let(:error_body) { { errors: [{ detail: 'Not found' }] }.to_json }

      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 404, body: error_body)
      end

      it 'returns error body and status without raising' do
        expect(subject).to eq({ body: error_body, status: 404 })
      end
    end

    context 'with multiple path parameters' do
      let(:endpoint_path) { '/v3/some/{type}/endpoint/{id}' }
      let(:params) { { 'type' => 'foo', 'id' => '123' } }
      let(:endpoint_url) { "#{siade_entreprise_url}/v3/some/foo/endpoint/123" }
      let(:response_body) { { data: {} }.to_json }

      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: response_body)
      end

      it 'substitutes all path parameters' do
        expect(subject).to eq({ body: response_body, status: 200 })
      end
    end

    context 'with query parameters' do
      let(:endpoint_path) { '/v3/dss/quotient_familial/identite' }
      let(:params) { { 'nom' => 'Dupont', 'prenoms' => 'Jean Pierre' } }
      let(:endpoint_url) { "#{siade_entreprise_url}/v3/dss/quotient_familial/identite" }
      let(:response_body) { { data: {} }.to_json }
      let(:expected_query_params) { siade_params.merge('nom' => 'Dupont', 'prenoms' => 'Jean Pierre') }

      before do
        stub_request(:get, endpoint_url)
          .with(query: expected_query_params, headers: siade_headers)
          .to_return(status: 200, body: response_body)
      end

      it 'includes query parameters in the request' do
        expect(subject).to eq({ body: response_body, status: 200 })
      end
    end

    context 'with custom context and object' do
      let(:endpoint_path) { '/v3/dss/quotient_familial/identite' }
      let(:params) { { 'context' => 'Admin custom trace', 'object' => 'user_42' } }
      let(:endpoint_url) { "#{siade_entreprise_url}/v3/dss/quotient_familial/identite" }
      let(:response_body) { { data: {} }.to_json }
      let(:expected_query_params) do
        {
          context: 'Admin custom trace',
          recipient: '13002526500013',
          object: 'user_42'
        }
      end

      before do
        stub_request(:get, endpoint_url)
          .with(query: expected_query_params, headers: siade_headers)
          .to_return(status: 200, body: response_body)
      end

      it 'overrides default metadata query params' do
        expect(subject).to eq({ body: response_body, status: 200 })
      end
    end

    context 'with blank context and object' do
      let(:endpoint_path) { '/v3/dss/quotient_familial/identite' }
      let(:params) { { 'context' => '', 'object' => '', 'nom' => 'Dupont' } }
      let(:endpoint_url) { "#{siade_entreprise_url}/v3/dss/quotient_familial/identite" }
      let(:response_body) { { data: {} }.to_json }
      let(:expected_query_params) { siade_params.merge('nom' => 'Dupont') }

      before do
        stub_request(:get, endpoint_url)
          .with(query: expected_query_params, headers: siade_headers)
          .to_return(status: 200, body: response_body)
      end

      it 'falls back to default metadata query params' do
        expect(subject).to eq({ body: response_body, status: 200 })
      end
    end
  end
end
