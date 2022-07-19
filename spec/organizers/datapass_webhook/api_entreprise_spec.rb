# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::APIEntreprise, type: :interactor do
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) { build(:datapass_webhook, event: 'validate_application', authorization_request_attributes: { copied_from_enrollment_id: previous_enrollment_id }) }
  let(:previous_enrollment_id) { rand(9001).to_s }
  let(:token) { create(:token) }

  before do
    create(:scope, code: 'entreprises', api: 'entreprise')

    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)

    create(:authorization_request, external_id: previous_enrollment_id, token:)
  end

  it { is_expected.to be_a_success }

  it 'creates a user' do
    expect {
      subject
    }.to change(User, :count).by(1)
  end

  it 'creates an authorization request' do
    expect {
      subject
    }.to change(AuthorizationRequest, :count).by(1)
  end

  it 'creates token for API Entreprise and stores id in token_id' do
    expect {
      subject
    }.to change(Token, :count).by(1)

    token = Token.last

    expect(subject.token_id).to eq(token.id)
    expect(token.api).to eq('entreprise')
  end

  it 'archives previous token' do
    expect {
      subject
    }.to change { token.reload.archived }.to(true)
  end
end
