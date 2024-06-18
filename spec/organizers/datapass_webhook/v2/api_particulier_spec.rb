# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::V2::APIParticulier, type: :interactor do
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) do
    params = build(:datapass_webhook_v2, event: 'approve')

    %w[family_name given_name email phone_number job_title].each do |attribute|
      params['data']['data'].delete "contact_metier_#{attribute}"
    end

    params['data']['data']['scopes'] = ['cnaf_quotient_familial']

    params
  end

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
  end

  it_behaves_like 'datapass webhooks', 'v2'

  it 'creates an authorization request with particulier api' do
    expect(subject.authorization_request.api).to eq('particulier')
  end

  it 'does not creates contact metier' do
    expect {
      subject
    }.not_to change(UserAuthorizationRequestRole.where(role: 'contact_metier'), :count)
  end

  it 'creates token for API Particulier' do
    subject

    last_token = Token.last

    expect(last_token.api).to eq('particulier')
  end

  describe 'Mailjet adding contacts' do
    it 'adds contacts to Entreprise mailjet list' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        id: Rails.application.credentials.mj_list_id_particulier!,
        action: 'addnoforce',
        contacts: [
          {
            email: 'applicant@gouv.fr',
            properties: {
              'contact_demandeur' => true,
              'contact_technique' => false,
              'nom' => 'Demandeur',
              'prénom' => 'Nicolas'
            }
          },
          {
            email: 'tech@gouv.fr',
            properties: {
              'contact_demandeur' => false,
              'contact_technique' => true,
              'nom' => 'Tech',
              'prénom' => 'Jean'
            }
          }
        ]
      )

      subject
    end
  end
end
