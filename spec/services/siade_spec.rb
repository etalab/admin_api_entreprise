require 'rails_helper'

RSpec.describe Siade, type: :service do
  include_context 'with siade payloads'

  let(:token) { create(:jwt_api_entreprise) }
  let(:siade_url) { Rails.application.credentials.siade_url }
  let(:siade_params) do
    {
      context: 'Admin API Entreprise',
      recipient: 'dummy siret',
      object: 'Admin API Entreprise request from Attestations Downloader'
    }
  end
  let(:siade_headers) { { Authorization: 'Bearer dummy token rehash' } }
  let(:siret) { siret_valid }
  let(:siren) { siren_valid }

  before { allow(token).to receive(:rehash).and_return('dummy token rehash') }

  describe '#entreprise', type: :request do
    subject { described_class.new(token: token).entreprises(siret: siret) }

    let(:endpoint_url) { "#{siade_url}v2/entreprises/#{siret}" }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_entreprise.to_json)
      end

      it 'returns correct result' do
        expect(subject['entreprise']['raison_sociale']).to eq('dummy name')
      end
    end

    context 'when it is not found (404)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 404)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 404, message: '404 Not Found'))
        )
      end
    end
  end

  describe '#attestations_sociales', type: :request do
    subject { described_class.new(token: token).attestations_sociales(siren: siren) }

    let(:endpoint_url) { "#{siade_url}v2/attestations_sociales_acoss/#{siren}" }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_attestation_sociale.to_json)
      end

      it 'returns correct result' do
        expect(subject['url']).to eq('http://entreprise.api.gouv.fr/uploads/attestation_sociale.pdf')
      end
    end

    context 'when token is unauthorized (401)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 401)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 401, message: '401 Unauthorized'))
        )
      end
    end
  end

  describe '#attestations_fiscales', type: :request do
    subject { described_class.new(token: token).attestations_fiscales(siren: siren) }

    let(:endpoint_url) { "#{siade_url}v2/attestations_fiscales_dgfip/#{siren}" }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_attestation_fiscale.to_json)
      end

      it 'returns correct result' do
        expect(subject['url']).to eq('http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
      end
    end

    context 'with invalid params (422)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 422)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 422, message: '422 Unprocessable Entity'))
        )
      end
    end
  end
end
