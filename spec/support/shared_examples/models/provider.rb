require 'rails_helper'

RSpec.shared_examples 'a provider model' do |options = {}|
  describe '.all' do
    subject { described_class.all }

    it 'returns a list of providers' do
      expect(subject).to all be_a(described_class)
    end
  end

  describe '#users' do
    subject { described_class.find(provider_uid).users }

    let(:provider_uid) { options[:provider_uid] || 'insee' }
    let!(:valid_user) { create(:user, provider_uids: [provider_uid, 'other_provider']) }
    let!(:invalid_user) { create(:user, provider_uids: %w[other_provider another_provider]) }

    it { is_expected.to eq([valid_user]) }
  end

  if options[:routes_test]
    describe '#routes' do
      subject { described_class.find(provider_uid).routes }

      let(:provider_uid) { options[:provider_uid] || 'insee' }
      let(:expected_routes) { options[:expected_routes] || [] }

      it 'includes all routes related to the provider' do
        expect(subject).to match_array(expected_routes)
      end
    end
  end
end
