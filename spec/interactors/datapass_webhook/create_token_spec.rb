# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::CreateToken, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request:)) }

  let(:authorization_request) { create(:authorization_request) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }
  let(:scopes) { build(:datapass_webhook_pass_model)['scopes'].keys }

  before do
    Timecop.freeze

    scopes.each do |scope|
      create(:scope, code: scope)
    end
  end

  after do
    Timecop.return
  end

  context 'when event is not validate_application' do
    let(:event) { 'whatever' }

    it { is_expected.to be_a_success }

    it 'does not create a new token token' do
      expect {
        subject
      }.not_to change(Token, :count)
    end
  end

  context 'when event is validate_application' do
    let(:event) { 'validate_application' }

    it { is_expected.to be_a_success }

    it { expect(subject.token_id).to be_present }

    it 'creates a new token token with valid attributes and scopes' do
      expect {
        subject
      }.to change(Token, :count)

      token = Token.last

      expect(token.authorization_request).to eq(authorization_request)
      expect(token.exp).to eq(18.months.from_now.to_i)
      expect(token.iat).to eq(Time.zone.now.to_i)

      expect(token.scopes.pluck(:code).sort).to eq(%w[associations entreprises])
    end
  end
end
