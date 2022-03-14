require 'rails_helper'

RSpec.describe Siade, type: :service do
  let(:token) { 'dummy token' }
  let(:siade_url) { Rails.application.credentials.siade_url }
  let(:siade_params) do
    {
      token: 'dummy token',
      context: 'Admin API Entreprise',
      recipient: '13002526500013',
      object: 'Admin API Entreprise request from Attestations Downloader'
    }
  end
  let(:siret) { siret_valid }
  let(:siren) { siren_valid }

  describe '#entreprise', type: :request do
    subject { described_class.new(token: token).entreprises(siret: siret) }

    let(:endpoint_url) { "#{siade_url}v2/entreprises/#{siret}" }
    let(:result) { { entreprise: 'dummy' } }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params)
          .to_return(status: 200, body: result.to_json)
      end

      it 'returns correct result' do
        expect(subject['entreprise']).to eq('dummy')
      end
    end
  end

  describe '#attestations_sociales', type: :request do
    subject { described_class.new(token: token).attestations_sociales(siren: siren) }

    let(:endpoint_url) { "#{siade_url}v2/attestations_sociales_acoss/#{siren}" }
    let(:result) { { url: 'dummy' } }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params)
          .to_return(status: 200, body: result.to_json)
      end

      it 'returns correct result' do
        expect(subject['url']).to eq('dummy')
      end
    end
  end

  describe '#attestations_fiscales', type: :request do
    subject { described_class.new(token: token).attestations_fiscales(siren: siren) }

    let(:endpoint_url) { "#{siade_url}v2/attestations_fiscales_dgfip/#{siren}" }
    let(:result) { { url: 'dummy' } }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params)
          .to_return(status: 200, body: result.to_json)
      end

      it 'returns correct result' do
        expect(subject['url']).to eq('dummy')
      end
    end
  end
end
