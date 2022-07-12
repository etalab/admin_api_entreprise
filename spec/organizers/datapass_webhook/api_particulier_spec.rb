# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::APIParticulier, type: :interactor do
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) { build(:datapass_webhook, event: 'validate_application', authorization_request_attributes: { scopes: { 'cnaf_quotient_familial' => true } }) }

  before do
    create(:scope, code: 'cnaf_quotient_familial', api: 'particulier')
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

  it 'creates token for API Particulier' do
    expect {
      subject
    }.to change(Token, :count).by(1)

    token = Token.last

    expect(token.api).to eq('particulier')
  end
end
