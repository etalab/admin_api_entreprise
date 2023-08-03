# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::APIParticulier, type: :interactor do
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) do
    build(:datapass_webhook,
      event: 'validate_application',
      authorization_request_attributes: {
        scopes: { 'cnaf_quotient_familial' => true },
        team_members: team_members_payload
      },
      extra_data: { 'external_token_id' => legacy_token_id })
  end

  let(:team_members_payload) do
    [
      build(:datapass_webhook_team_member_model, type: 'demandeur'),
      build(:datapass_webhook_team_member_model, type: 'responsable_technique'),
      build(:datapass_webhook_team_member_model, type: 'contact_metier')
    ]
  end

  let(:previous_enrollment_id) { rand(9001).to_s }

  let(:legacy_token_id) { 'over-9000' }

  it_behaves_like 'datapass webhooks'

  it 'creates an authorization request with particulier api' do
    expect(subject.authorization_request.api).to eq('particulier')
  end

  it 'creates token for API Particulier, with legacy token id in extra infos' do
    subject

    last_token = Token.last

    expect(last_token.api).to eq('particulier')
    expect(last_token.extra_info).to have_key('legacy_token_id')
    expect(last_token.extra_info['legacy_token_id']).to eq(legacy_token_id)
  end

  describe 'when contact metier is empty (non-regression test)' do
    before do
      datapass_webhook_params['data']['pass']['team_members'].each do |team_member_json|
        next unless team_member_json['type'] == 'contact_metier'

        team_member_json['family_name'] = nil
        team_member_json['given_name'] = nil
        team_member_json['email'] = nil
      end
    end

    it 'creates token for API Particulier and stores id in token_id' do
      expect {
        subject
      }.to change(Token, :count).by(1)

      token = Token.find(subject.token_id)

      expect(token.api).to eq('particulier')
    end
  end
end
