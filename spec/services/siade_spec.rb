require 'rails_helper'

RSpec.describe Siade, type: :service do
  let(:payload_error) { { errors: [{ detail: 'error' }] }.to_json }

  let(:payload_entreprise) do
    File.read('spec/fixtures/insee_unite_legale_example.json')
  end

  let(:payload_attestation_sociale) do
    {
      data: {
        document_url: 'https://entreprise.api.gouv.fr/files/attestation-vigilance-urssaf-exemple.pdf'
      }
    }.to_json
  end

  let(:payload_attestation_fiscale) do
    {
      data: {
        document_url: 'https://entreprise.api.gouv.fr/files/attestation-fiscale-dgfip-exemple.pdf'
      }
    }.to_json
  end

  let(:authorization_request) { create(:authorization_request, siret: siret_valid) }
  let(:token) { create(:token, authorization_request:) }
  let(:siade_url) { Rails.application.credentials.siade_url }
  let(:siade_params) do
    {
      context: 'Admin API Entreprise',
      recipient: siret_valid,
      object: 'Admin API Entreprise request from Attestations Downloader'
    }
  end
  let(:siade_headers) do
    {
      Authorization: "Bearer #{token.rehash}"
    }
  end
  let(:siren) { siren_valid }

  describe '#entreprise' do
    subject { described_class.new(token:).entreprises(siren:) }

    let(:endpoint_url) { "#{siade_url}/v3/insee/sirene/unites_legales/#{siren}" }

    context 'when it is a OK response' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_entreprise)
      end

      it 'returns correct result' do
        expect(subject['personne_morale_attributs']['raison_sociale']).to eq('DIRECTION INTERMINISTERIELLE DU NUMERIQUE')
      end
    end

    context 'when it is not found response' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 404, body: payload_error)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(
          an_instance_of(SiadeClientError).and(having_attributes(code: 404, message: 'error'))
        )
      end
    end
  end

  describe '#attestations_sociales' do
    subject { described_class.new(token:).attestations_sociales(siren:) }

    let(:endpoint_url) { "#{siade_url}/v4/urssaf/unites_legales/#{siren}/attestation_vigilance" }

    context 'when it is a OK response' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_attestation_sociale)
      end

      it 'returns correct result' do
        expect(subject['document_url']).to eq('https://entreprise.api.gouv.fr/files/attestation-vigilance-urssaf-exemple.pdf')
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
          an_instance_of(SiadeClientError).and(having_attributes(code: 401, message: 'error'))
        )
      end
    end
  end

  describe '#attestations_fiscales' do
    subject { described_class.new(token:).attestations_fiscales(siren:) }

    let(:endpoint_url) { "#{siade_url}/v4/dgfip/unites_legales/#{siren}/attestation_fiscale" }

    context 'when it is a OK response' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_attestation_fiscale)
      end

      it 'returns correct result' do
        expect(subject['document_url']).to eq('https://entreprise.api.gouv.fr/files/attestation-fiscale-dgfip-exemple.pdf')
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
          an_instance_of(SiadeClientError).and(having_attributes(code: 422, message: 'error'))
        )
      end
    end
  end
end
