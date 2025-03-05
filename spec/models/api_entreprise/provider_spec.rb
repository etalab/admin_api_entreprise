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
end
