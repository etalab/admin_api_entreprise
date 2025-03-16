require 'rails_helper'

RSpec.describe APIEntreprise::Provider do
  describe '.all' do
    subject { described_class.all }

    it 'returns a list of providers' do
      expect(subject).to all be_a(described_class)
    end
  end

  describe '#users' do
    subject { described_class.find('infogreffe').users }

    let!(:valid_user) { create(:user, provider_uids: %w[infogreffe bdf]) }
    let!(:invalid_user) { create(:user, provider_uids: %w[bdf inpi]) }

    it { is_expected.to eq([valid_user]) }
  end

  describe '#routes' do
    subject { described_class.find('insee').routes }

    it 'includes alll routes related to the provider' do
      expect(subject).to contain_exactly(
        '/v3/insee/sirene/etablissements/{siret}/adresse',
        '/v3/insee/sirene/etablissements/diffusibles/{siret}/adresse',
        '/v3/insee/sirene/etablissements/{siret}',
        '/v3/insee/sirene/etablissements/diffusibles/{siret}',
        '/v3/insee/sirene/unites_legales/diffusibles/{siren}/siege_social',
        '/v3/insee/sirene/unites_legales/{siren}/siege_social',
        '/v3/insee/sirene/etablissements/{siret}/successions',
        '/v3/insee/sirene/unites_legales/{siren}',
        '/v3/insee/sirene/unites_legales/diffusibles/{siren}'
      )
    end
  end
end
