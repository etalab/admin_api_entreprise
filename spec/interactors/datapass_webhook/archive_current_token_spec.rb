require 'rails_helper'

RSpec.describe DatapassWebhook::ArchiveCurrentToken, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request:)) }

  let(:token) { create(:token) }

  let(:authorization_request) { create(:authorization_request, tokens: [token]) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }

  context "when event is not 'archive'" do
    let(:event) { 'whatever' }

    it { is_expected.to be_a_success }

    it 'does not archive current token' do
      expect {
        subject
      }.not_to change { Token.where(archived: true).count }
    end
  end

  context "when event is 'archive'" do
    let(:event) { %w[archive].sample }

    it { is_expected.to be_a_success }

    it 'does archive current token' do
      expect {
        subject
      }.to change { Token.where(archived: true).count }
    end
  end
end
