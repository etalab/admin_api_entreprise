require 'rails_helper'

RSpec.describe DatapassWebhook::ArchiveCurrentAuthorizationRequest, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request:)) }

  let(:token) { create(:token) }

  let(:authorization_request) { create(:authorization_request, tokens: [token]) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }

  context "when event is not 'archive'" do
    let(:event) { 'whatever' }

    it { is_expected.to be_a_success }

    it 'does not archive current authorization_request' do
      expect {
        subject
      }.not_to change { AuthorizationRequest.where(status: 'archived').count }
    end
  end

  context "when event is 'archive'" do
    let(:event) { %w[archive].sample }

    it { is_expected.to be_a_success }

    it 'updates the authorization request status' do
      expect {
        subject
      }.to change { AuthorizationRequest.where(status: 'archived').count }
    end
  end
end
