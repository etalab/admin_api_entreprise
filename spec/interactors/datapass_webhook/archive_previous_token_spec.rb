require 'rails_helper'

RSpec.describe DatapassWebhook::ArchivePreviousToken, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request: authorization_request)) }

  let(:authorization_request) { create(:authorization_request, previous_external_id: previous_external_id) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event: event) }

  let(:jwt_api_entreprise) { create(:jwt_api_entreprise) }

  before do
    if previous_external_id
      create(:authorization_request, jwt_api_entreprise: jwt_api_entreprise, external_id: previous_external_id)
    end
  end

  context 'when event is validate_application' do
    let(:event) { 'validate_application' }

    context 'when authorization request has a previous external id' do
      let(:previous_external_id) { rand(9001).to_s }

      it 'archives previous token' do
        expect {
          subject
        }.to change { jwt_api_entreprise.reload.archived }.to(true)
      end
    end

    context 'when authorization request has no previous external id' do
      let(:previous_external_id) { nil }

      it 'does nothing' do
        expect {
          subject
        }.not_to change { JwtAPIEntreprise.where(archived: true).count }
      end
    end
  end

  context 'when event is not validate_application' do
    let(:event) { 'sent' }

    context 'when authorization request has a previous external id' do
      let(:previous_external_id) { rand(9001).to_s }

      it 'does nothing' do
        expect {
          subject
        }.not_to change { JwtAPIEntreprise.where(archived: true).count }
      end
    end
  end
end
