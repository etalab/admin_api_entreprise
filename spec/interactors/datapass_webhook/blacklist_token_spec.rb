RSpec.describe DatapassWebhook::BlacklistToken, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request:)) }

  let(:authorization_request) { create(:authorization_request, tokens: [token]) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }

  let(:token) { create(:token) }

  context 'when event is revoke' do
    let(:event) { 'revoke' }

    it 'blacklist the given token' do
      expect {
        subject
      }.to change { token.reload.blacklisted }.to(true)
    end
  end

  context 'when event is not revoke' do
    let(:event) { %w[validate_application] }

    it 'does not do anything' do
      expect {
        subject
      }.not_to change { Token.where(blacklisted: true).count }
    end
  end
end
