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

  context 'when modalities does no include params' do
    before do
      datapass_webhook_params['data']['data']['modalities'] = ['formulaire_qf']
    end

    it 'does not create a token' do
      expect {
        subject
      }.not_to change(Token, :count)
    end
  end

  describe 'modalities' do
    context 'when modalities does not include formulaire_qf' do
      before do
        datapass_webhook_params['data']['data']['modalities'] = ['params']
      end

      it 'does not schedule a job to create formulaire qf access on HubEE' do
        expect {
          subject
        }.not_to have_enqueued_job(CreateFormulaireQFHubEESubscriptionJob)
      end
    end

    context 'when modalities include formulaire_qf' do
      before do
        datapass_webhook_params['data']['data']['modalities'] = ['formulaire_qf']
      end

      context 'when event is approve' do
        before do
          datapass_webhook_params['event'] = 'approve'
        end

        it 'schedules a job to create formulaire qf access on HubEE' do
          expect {
            subject
          }.to have_enqueued_job(CreateFormulaireQFHubEESubscriptionJob)
        end
      end

      context 'when event not approve' do
        before do
          datapass_webhook_params['event'] = 'reject'
        end

        it 'does not schedule a job to create formulaire qf access on HubEE' do
          expect {
            subject
          }.not_to have_enqueued_job(CreateFormulaireQFHubEESubscriptionJob)
        end
      end
    end
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

  it 'affects authorization request data to authorization_request_data on context' do
    expect(subject.authorization_request_data).to eq(datapass_webhook_params['data']['data'])
  end
end
