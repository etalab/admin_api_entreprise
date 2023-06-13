# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::APIParticulier, type: :interactor do
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) { build(:datapass_webhook, event: 'validate_application', authorization_request_attributes: { scopes: { 'cnaf_quotient_familial' => true }, team_members: team_members_payload }, extra_data: { 'external_token_id' => legacy_token_id }) }
  let(:team_members_payload) do
    [
      build(:datapass_webhook_team_member_model, type: 'demandeur'),
      build(:datapass_webhook_team_member_model, type: 'responsable_technique')
    ]
  end
  let(:legacy_token_id) { 'over-9000' }

  it { is_expected.to be_a_success }

  it 'creates one demandeur' do
    expect {
      subject
    }.to change(UserAuthorizationRequestRole.where(role: 'demandeur'), :count).by(1)
  end

  it 'creates one contact technique' do
    expect {
      subject
    }.to change(UserAuthorizationRequestRole.where(role: 'contact_technique'), :count).by(1)
  end

  describe 'when demandeur and contact technique are the same' do
    let(:email) { generate(:email) }

    before do
      datapass_webhook_params['data']['pass']['team_members'].map do |team_member_json|
        team_member_json['family_name'] = 'Dupont'
        team_member_json['given_name'] = 'Jean'
        team_member_json['email'] = email
      end
    end

    it 'creates one demandeur' do
      expect {
        subject
      }.to change(UserAuthorizationRequestRole.where(role: 'demandeur'), :count).by(1)
    end

    it 'creates one contact technique' do
      expect {
        subject
      }.to change(UserAuthorizationRequestRole.where(role: 'contact_technique'), :count).by(1)
    end
  end

  it 'creates an authorization request with particulier api' do
    expect {
      subject
    }.to change(AuthorizationRequest, :count).by(1)

    expect(subject.authorization_request.api).to eq('particulier')
  end

  it 'creates token for API Particulier, with legacy token id in extra infos' do
    expect {
      subject
    }.to change(Token, :count).by(1)

    token = Token.last

    expect(token.api).to eq('particulier')
    expect(token.extra_info).to have_key('legacy_token_id')
    expect(token.extra_info['legacy_token_id']).to eq(legacy_token_id)
  end
end
