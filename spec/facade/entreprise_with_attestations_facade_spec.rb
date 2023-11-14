require 'rails_helper'

RSpec.describe EntrepriseWithAttestationsFacade do
  subject do
    instance = described_class.new(token:, siren:)
    instance.perform
    instance
  end

  let(:token) { create(:token) }
  let(:siren) { '123456789' }
  let(:siade_double) { instance_double(Siade) }

  before do
    allow(Siade).to receive(:new).and_return(siade_double)

    allow(siade_double).to receive(:attestations_sociales).and_raise(SiadeClientError.new('403', 'Forbidden'))
    allow(siade_double).to receive(:attestations_fiscales).and_raise(SiadeClientError.new('403', 'Forbidden'))
  end

  context 'when entreprise can be retrieved' do
    before do
      allow(siade_double).to receive(:entreprises).and_return(attributes_for(:entreprise))
    end

    it { is_expected.to be_a_success }

    its(:entreprise) { is_expected.to be_a(Entreprise) }

    context 'when attestation fiscale succeed' do
      before do
        allow(siade_double).to receive(:attestations_fiscales).and_return({
          'document_url' => 'https://attestation-fiscale.com/attestation.pdf'
        })
      end

      its(:attestation_fiscale_url) { is_expected.to eq('https://attestation-fiscale.com/attestation.pdf') }
    end

    context 'when attestation fiscale failed' do
      before do
        allow(siade_double).to receive(:attestations_fiscales).and_raise(SiadeClientError.new('403', 'Forbidden'))
      end

      its(:attestation_fiscale_url) { is_expected.to be_nil }
    end
  end
end
