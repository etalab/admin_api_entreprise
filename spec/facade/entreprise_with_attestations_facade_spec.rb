require 'rails_helper'

RSpec.describe EntrepriseWithAttestationsFacade do
  subject { described_class.new(token:, siren:) }

  include_context 'with siade payloads'

  let(:token) { create(:token, scopes: %w[attestations_sociales attestations_fiscales]) }
  let(:siren) { '123456789' }
  let(:siade_double) { instance_double(Siade) }

  before do
    allow(Siade).to receive(:new).and_return(siade_double)
  end

  describe 'entreprise data' do
    before do
      allow(siade_double).to receive(:entreprises).and_return(JSON.parse(payload_entreprise)['data'])
      subject.retrieve_company
    end

    its(:entreprise_raison_sociale) { is_expected.to eq('DIRECTION INTERMINISTERIELLE DU NUMERIQUE') }
    its(:entreprise_forme_juridique_libelle) { is_expected.to eq("Service central d'un ministère") }
    its(:categorie_entreprise) { is_expected.to eq('GE') }
    its(:entreprise_naf_full) { is_expected.to eq('8411Z - Administration publique générale') }
  end

  describe '#attestation_sociale_url' do
    before do
      allow(siade_double).to receive(:attestations_sociales).and_return(JSON.parse(payload_attestation_sociale)['data'])
      subject.retrieve_attestation_sociale
    end

    context 'when token has attestations_sociales scope' do
      its(:attestation_sociale_url) { is_expected.to eq('https://storage.entreprise.api.gouv.fr/url-de-telechargement-attestation-vigilance.pdf') }
    end

    context 'when token does not have attestations_sociales scope' do
      let(:token) { create(:token, scopes: ['other']) }

      its(:attestation_sociale_url) { is_expected.to be_nil }
    end
  end

  describe '#attestation_fiscale_url' do
    before do
      allow(siade_double).to receive(:attestations_fiscales).and_return(JSON.parse(payload_attestation_fiscale)['data'])
      subject.retrieve_attestation_fiscale
    end

    context 'when token has attestations_fiscales scope' do
      its(:attestation_fiscale_url) { is_expected.to eq('https://entreprise.api.gouv.fr/files/attestation-fiscale-dgfip-exemple.pdf') }
    end

    context 'when token does not have attestations_fiscales scope' do
      let(:token) { create(:token, scopes: ['other']) }

      its(:attestation_fiscale_url) { is_expected.to be_nil }
    end
  end

  describe '#with_attestation_fiscale?' do
    subject { described_class.new(token:, siren:).with_attestation_fiscale? }

    context 'when token has attestations_fiscales scope' do
      let(:token) { create(:token, :with_specific_scopes, specific_scopes: ['attestations_fiscales']) }

      it { is_expected.to be_truthy }
    end

    context 'when token doesnt have attestations_fiscales scope' do
      let(:token) { create(:token, scopes: []) }

      it { is_expected.to be_falsy }
    end
  end

  describe '#with_attestation_sociale?' do
    subject { described_class.new(token:, siren:).with_attestation_sociale? }

    context 'when token has attestations sociales scope' do
      let(:token) { create(:token, :with_specific_scopes, specific_scopes: ['attestations_sociales']) }

      it { is_expected.to be_truthy }
    end

    context 'when token doesnt have attestations sociales scope' do
      let(:token) { create(:token, scopes: []) }

      it { is_expected.to be_falsy }
    end
  end
end
