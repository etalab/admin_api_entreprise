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
      build(:datapass_webhook_team_member_model, type: 'responsable_technique')
    ]
  end

  let(:previous_enrollment_id) { rand(9001).to_s }

  let(:legacy_token_id) { 'over-9000' }

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
  end

  it_behaves_like 'datapass webhooks'

  it 'creates an authorization request with particulier api' do
    expect(subject.authorization_request.api).to eq('particulier')
  end

  it 'does not creates contact metier' do
    expect {
      subject
    }.not_to change(UserAuthorizationRequestRole.where(role: 'contact_metier'), :count)
  end

  it 'creates token for API Particulier, with legacy token id in extra infos' do
    subject

    last_token = Token.last

    expect(last_token.api).to eq('particulier')
    expect(last_token.extra_info).to have_key('legacy_token_id')
    expect(last_token.extra_info['legacy_token_id']).to eq(legacy_token_id)
  end

  describe 'Mailjet adding contacts' do
    it 'adds contacts to Particulier mailjet list' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        id: Rails.application.credentials.mj_list_id_particulier!,
        action: 'addnoforce',
        contacts: [{ email: a_string_matching(/demandeur\d{1,4}@service.gouv.fr/),
                     properties: { 'contact_demandeur' => true,
                                   'contact_technique' => false,
                                   'nom' => 'demandeur last name',
                                   'prénom' => 'demandeur first name' } },
                   { email: a_string_matching(/responsable_technique\d{1,4}@service.gouv.fr/),
                     properties: { 'contact_demandeur' => false,
                                   'contact_technique' => true,
                                   'nom' => 'responsable_technique last name',
                                   'prénom' => 'responsable_technique first name' } }]
      )

      subject
    end
  end
end
