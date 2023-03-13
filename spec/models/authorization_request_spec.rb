require 'rails_helper'

RSpec.describe AuthorizationRequest do
  it 'has valid factory' do
    expect(build(:authorization_request)).to be_valid
  end

  describe 'contacts associations' do
    let(:authorization_request) { create(:authorization_request, :with_contacts) }

    it 'has valid association for contact technique and metier' do
      expect(authorization_request.contacts.count).to eq(2)

      expect(authorization_request.contact_technique).to be_present
      expect(authorization_request.contact_metier).to be_present
    end
  end

  describe 'authorization_request_for scope' do
    subject { described_class.authorization_requests_for('entreprise') }

    let!(:authorization_requests_entreprise) { create(:authorization_request, api: 'entreprise') }
    let!(:authorization_requests_particulier) { create(:authorization_request, api: 'particulier') }

    it { is_expected.to include(*authorization_requests_entreprise) }
    it { is_expected.not_to include(authorization_requests_particulier) }
  end

  describe 'active_token associations' do
    let(:authorization_request) do
      create(:authorization_request, :with_multiple_tokens_one_valid)
    end

    it 'returns a token' do
      expect(authorization_request.token).to be_present
    end

    it 'returns an active token' do
      expect(authorization_request.active_token).to be_present
      expect(authorization_request.token.id).to eq(authorization_request.active_token.id)
      expect(authorization_request.tokens.first.id).not_to eq(authorization_request.active_token.id)
    end
  end
end
