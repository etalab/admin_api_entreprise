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
      allow(siade_double).to receive(:entreprises).and_return(payload_entreprise)
      subject.retrieve_company
    end

    its(:entreprise_raison_sociale) { is_expected.to eq('dummy name') }
    its(:entreprise_forme_juridique) { is_expected.to eq('dummy forme juridique') }
    its(:categorie_entreprise) { is_expected.to eq('dummy cat. entreprise') }
    its(:entreprise_naf_full) { is_expected.to eq('dummy naf - dummy libelle naf') }
  end

  describe '#attestation_sociale_url' do
    before do
      allow(siade_double).to receive(:attestations_sociales).and_return(payload_attestation_sociale)
      subject.retrieve_attestation_sociale
    end

    context 'when token has attestations_sociales scope' do
      its(:attestation_sociale_url) { is_expected.to eq('http://entreprise.api.gouv.fr/uploads/attestation_sociale.pdf') }
    end

    context 'when token does not have attestations_sociales scope' do
      let(:token) { create(:token, scopes: ['other']) }

      its(:attestation_sociale_url) { is_expected.to be_nil }
    end
  end

  describe '#attestation_fiscale_url' do
    before do
      allow(siade_double).to receive(:attestations_fiscales).and_return(payload_attestation_fiscale)
      subject.retrieve_attestation_fiscale
    end

    context 'when token has attestations_fiscales scope' do
      its(:attestation_fiscale_url) { is_expected.to eq('http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf') }
    end

    context 'when token does not have attestations_fiscales scope' do
      let(:token) { create(:token, scopes: ['other']) }

      its(:attestation_fiscale_url) { is_expected.to be_nil }
    end
  end
end
