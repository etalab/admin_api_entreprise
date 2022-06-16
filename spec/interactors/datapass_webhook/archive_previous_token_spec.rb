require 'rails_helper'

RSpec.describe DatapassWebhook::ArchivePreviousToken, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request:)) }

  let(:authorization_request) { create(:authorization_request, previous_external_id:) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }

  let(:token) { create(:token) }

  before do
    create(:authorization_request, token:, external_id: previous_external_id) if previous_external_id
  end

  context 'when event is validate_application or validate' do
    let(:event) { %w[validate_application validate].sample }

    context 'when authorization request has a previous external id' do
      let(:previous_external_id) { rand(9001).to_s }

      it 'archives previous token' do
        expect {
          subject
        }.to change { token.reload.archived }.to(true)
      end
    end

    context 'when authorization request has no previous external id' do
      let(:previous_external_id) { nil }

      it 'does nothing' do
        expect {
          subject
        }.not_to change { Token.where(archived: true).count }
      end
    end
  end

  context 'when event is not validate_application' do
    let(:event) { %w[send_application submit] }

    context 'when authorization request has a previous external id' do
      let(:previous_external_id) { rand(9001).to_s }

      it 'does nothing' do
        expect {
          subject
        }.not_to change { Token.where(archived: true).count }
      end
    end
  end
end
