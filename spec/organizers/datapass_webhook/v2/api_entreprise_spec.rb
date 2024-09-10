# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::V2::APIEntreprise, type: :interactor do
  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) do
    build(
      :datapass_webhook_v2,
      event: 'approve',
      demarche: 'editeurs'
    )
  end

  let(:token) { create(:token) }

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
  end

  it_behaves_like 'datapass webhooks', 'v2'

  it 'creates one contact metier' do
    expect { subject }.to change(UserAuthorizationRequestRole.where(role: 'contact_metier'), :count).by(1)
  end

  it 'creates an authorization request with entreprise api, demarche and public id' do
    expect(subject.authorization_request.api).to eq('entreprise')
    expect(subject.authorization_request.demarche).to eq('api-entreprise')
    expect(subject.authorization_request.public_id).to be_present
  end

  describe 'when contact metier is empty (non-regression test)' do
    before do
      %w[family_name given_name email phone_number job_title].each do |attribute|
        datapass_webhook_params['data']['data']["contact_metier_#{attribute}"] = nil
      end
    end

    it 'creates token for API Entreprise and stores id in token_id' do
      expect {
        subject
      }.to change(Token, :count).by(1)

      token = Token.find(subject.token_id)

      expect(token.api).to eq('entreprise')
    end
  end

  describe 'Mailjet adding contacts' do
    it 'adds contacts to Entreprise mailjet list' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        id: Rails.application.credentials.mj_list_id_entreprise!,
        action: 'addnoforce',
        contacts: [
          {
            email: 'applicant@gouv.fr',
            properties: {
              'contact_demandeur' => true,
              'contact_métier' => false,
              'contact_technique' => false,
              'nom' => 'Demandeur',
              'prénom' => 'Nicolas'
            }
          },
          {
            email: 'metier@gouv.fr',
            properties: {
              'contact_demandeur' => false,
              'contact_métier' => true,
              'contact_technique' => false,
              'nom' => 'Metier',
              'prénom' => 'Jacques'
            }
          },
          {
            email: 'tech@gouv.fr',
            properties: {
              'contact_demandeur' => false,
              'contact_métier' => false,
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

  describe 'when demandeur, contact technique and contact metier are the same' do
    let(:email) { generate(:email) }

    before do
      %w[contact_metier contact_technique].each do |role|
        %w[family_name given_name email].each do |attribute|
          datapass_webhook_params['data']['data']["#{role}_#{attribute}"] = datapass_webhook_params['data']['applicant'][attribute]
        end
      end
    end

    it 'creates one contact metier' do
      expect {
        subject
      }.to change(UserAuthorizationRequestRole.where(role: 'contact_metier'), :count).by(1)
    end
  end
end
