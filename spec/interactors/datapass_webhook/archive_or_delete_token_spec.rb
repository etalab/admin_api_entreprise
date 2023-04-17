RSpec.describe DatapassWebhook::ArchiveOrDeleteToken, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request:)) }

  let(:authorization_request) { create(:authorization_request, tokens: [token]) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }

  let!(:token) { create(:token) }

  context 'when event is archive' do
    let(:event) { 'archive' }

    context 'when token is already blacklisted' do
      let(:token) { create(:token, blacklisted: true) }

      it 'archives the given token' do
        expect {
          subject
        }.to change { token.reload.archived }.to(true)
      end
    end

    context 'when token is not yet blacklisted' do
      it 'removes the given token' do
        expect {
          subject
        }.to change { Token.all.count }
      end
    end
  end

  context 'when event is not archive' do
    let(:event) { 'validate_application' }

    it 'does not do anything' do
      expect {
        subject
      }.not_to change { Token.where(archived: true).count }

      expect {
        subject
      }.not_to change { Token.all.count }
    end
  end
end
