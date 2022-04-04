# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::CreateJwtToken, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(authorization_request:)) }

  let(:authorization_request) { create(:authorization_request) }
  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }
  let(:roles) { build(:datapass_webhook_pass_model)['scopes'].keys }

  before do
    Timecop.freeze

    roles.each do |role|
      create(:role, code: role)
    end
  end

  after do
    Timecop.return
  end

  context 'when event is not validate_application' do
    let(:event) { 'whatever' }

    it { is_expected.to be_a_success }

    it 'does not create a new jwt token' do
      expect {
        subject
      }.not_to change { JwtAPIEntreprise.count }
    end
  end

  context 'when event is validate_application' do
    let(:event) { 'validate_application' }

    it { is_expected.to be_a_success }

    it { expect(subject.token_id).to be_present }

    it 'creates a new jwt token with valid attributes and roles' do
      expect {
        subject
      }.to change { JwtAPIEntreprise.count }

      token = JwtAPIEntreprise.last

      expect(token.authorization_request).to eq(authorization_request)
      expect(token.exp).to eq(18.months.from_now.to_i)
      expect(token.iat).to eq(Time.zone.now.to_i)

      expect(token.roles.pluck(:code).sort).to eq(%w[associations entreprises])
    end
  end
end
