require 'rails_helper'

RSpec.describe Siade, type: :service do
  include_context 'with siade payloads'

  let(:authorization_request) { create(:authorization_request, siret: 'dummy siret') }
  let(:token) { create(:jwt_api_entreprise, authorization_request:) }
  let(:siade_url) { Rails.application.credentials.siade_url }
  let(:siade_params) do
    {
      context: 'Admin API Entreprise',
      recipient: 'dummy siret',
      object: 'Admin API Entreprise request from Attestations Downloader'
    }
  end
  let(:siade_headers) { { Authorization: 'Bearer dummy token rehash' } }
  let(:siren) { siren_valid }

  before { allow(token).to receive(:rehash).and_return('dummy token rehash') }

  describe '#entreprise', type: :request do
    subject { described_class.new(token:).entreprises(siren:) }

    let(:endpoint_url) { "#{siade_url}/v2/entreprises/#{siren}" }

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

    context 'when called with empty string' do
      let(:siren) { ' ' }

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 422, message: 'Champ SIRET ou SIREN non rempli'))
        )
      end
    end

    context 'when it is not found (404)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 404, body: payload_error)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 404, message: 'Siade error msg'))
        )
      end
    end
  end

  describe '#attestations_sociales', type: :request do
    subject { described_class.new(token:).attestations_sociales(siren:) }

    let(:endpoint_url) { "#{siade_url}/v2/attestations_sociales_acoss/#{siren}" }

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

    context 'when called with empty string' do
      let(:siren) { ' ' }

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 422, message: 'Champ SIRET ou SIREN non rempli'))
        )
      end
    end

    context 'when token is unauthorized (401)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 401, body: payload_error)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 401, message: 'Siade error msg'))
        )
      end
    end
  end

  describe '#attestations_fiscales', type: :request do
    subject { described_class.new(token:).attestations_fiscales(siren:) }

    let(:endpoint_url) { "#{siade_url}/v2/attestations_fiscales_dgfip/#{siren}" }

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

    context 'when called with empty string' do
      let(:siren) { '' }

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 422, message: 'Champ SIRET ou SIREN non rempli'))
        )
      end
    end

    context 'with invalid params (422)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 422, body: payload_error)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 422, message: 'Siade error msg'))
        )
      end
    end
  end
end
