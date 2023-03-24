# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::APIEntreprise, type: :interactor do
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) { build(:datapass_webhook, event: 'validate_application', demarche: 'editeurs', authorization_request_attributes: { copied_from_enrollment_id: previous_enrollment_id }) }
  let(:previous_enrollment_id) { rand(9001).to_s }
  let(:token) { create(:token) }

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)

    create(:authorization_request, external_id: previous_enrollment_id, tokens: [token])
  end

  it { is_expected.to be_a_success }

  it 'creates a user' do
    expect {
      subject
    }.to change(User, :count).by(1)
  end

  it 'creates an authorization request with entreprise api and demarche' do
    expect {
      subject
    }.to change(AuthorizationRequest, :count).by(1)

    expect(subject.authorization_request.api).to eq('entreprise')
    expect(subject.authorization_request.demarche).to eq('editeurs')
  end

  it 'creates token for API Entreprise and stores id in token_id' do
    expect {
      subject
    }.to change(Token, :count).by(1)

    token = Token.find(subject.token_id)

    expect(token.api).to eq('entreprise')
  end

  it 'archives previous token' do
    expect {
      subject
    }.to change { token.reload.archived }.to(true)
  end

  context 'with a revoke token event' do
    let(:datapass_webhook_params) { build(:datapass_webhook, event: 'revoke') }

    it { is_expected.to be_a_success }

    it 'does not raise an error' do
      expect { subject }.not_to raise_error
    end
  end

  context 'with an archive token event' do
    let(:datapass_webhook_params) { build(:datapass_webhook, event: 'archive') }

    it { is_expected.to be_a_success }

    it 'does not raise an error' do
      expect { subject }.not_to raise_error
    end
  end

  context 'with a delete token event' do
    let(:datapass_webhook_params) { build(:datapass_webhook, event: 'delete') }

    it { is_expected.to be_a_success }

    it 'does not raise an error' do
      expect { subject }.not_to raise_error
    end
  end
end
