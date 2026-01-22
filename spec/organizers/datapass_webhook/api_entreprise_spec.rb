# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::APIEntreprise, type: :interactor do
  it_behaves_like 'a datapass webhook organizer', 'entreprise', :mj_list_id_entreprise! do
    let(:datapass_webhook_params) do
      build(:datapass_webhook,
        event: 'approve',
        demarche: 'editeurs',
        authorization_request_attributes: {
          copied_from_enrollment_id: previous_enrollment_id
        })
    end

    before do
      create(:authorization_request, external_id: previous_enrollment_id, tokens: [token])
    end
  end

  describe 'contact metier behavior' do
    subject { described_class.call(datapass_webhook_params) }

    let(:datapass_webhook_params) do
      build(:datapass_webhook,
        event: 'approve',
        demarche: 'editeurs',
        authorization_request_attributes: {
          copied_from_enrollment_id: previous_enrollment_id
        })
    end

    let(:previous_enrollment_id) { rand(9001).to_s }

    before do
      allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
      create(:authorization_request, external_id: previous_enrollment_id, tokens: [create(:token)])
    end

    it 'creates one contact metier' do
      expect { subject }.to change(UserAuthorizationRequestRole.where(role: 'contact_metier'), :count).by(1)
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

      it 'creates token for API Entreprise and stores id in token_id' do
        expect {
          subject
        }.to change(Token, :count).by(1)

        token = Token.find(subject.token_id)
        expect(token.api).to eq('entreprise')
      end

      it 'archives previous authorization_request' do
        expect {
          subject
        }.to change { AuthorizationRequest.where(status: 'archived').count }
      end
    end

    describe 'when demandeur, contact technique and contact metier are the same' do
      let(:email) { generate(:email) }

      before do
        datapass_webhook_params['data']['pass']['team_members'].map do |team_member_json|
          team_member_json['family_name'] = 'Dupont'
          team_member_json['given_name'] = 'Jean'
          team_member_json['email'] = email
        end
      end

      it 'creates one contact metier' do
        expect {
          subject
        }.to change(UserAuthorizationRequestRole.where(role: 'contact_metier'), :count).by(1)
      end
    end
  end
end
