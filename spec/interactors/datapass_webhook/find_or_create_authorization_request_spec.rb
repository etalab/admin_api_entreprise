# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::FindOrCreateAuthorizationRequest, type: :interactor do
  subject { described_class.call(datapass_webhook_params.merge(api: 'entreprise')) }

  let(:datapass_webhook_params) do
    build(:datapass_webhook, fired_at:, authorization_request_attributes: {
      id: authorization_id,
      team_members: team_members_payload
    })
  end
  let(:team_members_payload) do
    [
      demandeur,
      contact_metier,
      responsable_technique
    ]
  end
  let(:demandeur) { build(:datapass_webhook_team_member_model, type: 'demandeur') }
  let(:responsable_technique) { build(:datapass_webhook_team_member_model, type: 'responsable_technique') }
  let(:contact_metier) { build(:datapass_webhook_team_member_model, type: 'contact_metier') }

  let(:authorization_id) { rand(1..4000).to_s }
  let(:fired_at) { 2.minutes.ago.to_i }

  context 'when authorization request already exists' do
    let!(:authorization_request) do
      create(:authorization_request, :with_all_contacts, external_id: authorization_id)
    end

    it { is_expected.to be_a_success }
    it { expect(subject.authorization_request).to eq(authorization_request) }

    it 'updates attributes on existing authorization request' do
      expect {
        subject
      }.to change { authorization_request.reload.intitule }.to(datapass_webhook_params['data']['pass']['intitule'])

      expect(authorization_request.last_update.to_i).to eq(fired_at)
      expect(authorization_request.status).to eq('sent')
    end

    it 'updates contacts associated to authorization request' do
      expect(authorization_request.contact_metier.full_name).not_to eq('CONTACT_METIER LAST NAME contact_metier first name')
      expect(authorization_request.contact_technique.full_name).not_to eq('RESPONSABLE_TECHNIQUE LAST NAME responsable_technique first name')

      expect(authorization_request.contact_technique.email).not_to match(/technique\d+@/)
      expect(authorization_request.contact_metier.email).not_to match(/metier\d+@/)

      expect {
        subject
      }.not_to change { authorization_request.reload.contacts.count }

      expect(authorization_request.contact_technique.email).to match(/technique\d+@/)
      expect(authorization_request.contact_metier.email).to match(/metier\d+@/)

      expect(authorization_request.contact_metier.full_name).to eq('CONTACT_METIER LAST NAME contact_metier first name')
      expect(authorization_request.contact_technique.full_name).to eq('RESPONSABLE_TECHNIQUE LAST NAME responsable_technique first name')
    end

    context 'when it is the same demandeur' do
      let(:demandeur) { build(:datapass_webhook_team_member_model, type: 'demandeur', email: authorization_request.demandeur.email) }

      it 'does not update demandeur' do
        expect {
          subject
        }.not_to change { authorization_request.reload.demandeur }
      end
    end

    context 'when it is not the same demandeur' do
      it 'updates demandeur' do
        expect {
          subject
        }.to change { authorization_request.reload.demandeur }
      end
    end
  end

  context 'when authorization request does not exist' do
    it { is_expected.to be_a_success }
    it { expect(subject.authorization_request).to an_instance_of(AuthorizationRequest) }

    it 'creates a new authorization request with attributes (including siret) and contacts' do
      expect {
        subject
      }.to change(AuthorizationRequest, :count).by(1)

      authorization_request = AuthorizationRequest.last

      expect(authorization_request.intitule).to eq(datapass_webhook_params['data']['pass']['intitule'])
      expect(authorization_request.siret).to eq(datapass_webhook_params['data']['pass']['siret'])
      expect(authorization_request.previous_external_id).to eq(datapass_webhook_params['data']['pass']['copied_from_enrollment_id'])
      expect(authorization_request.contacts.count).to eq(2)
      expect(authorization_request.contact_technique.email).to match(/technique\d+@/)
      expect(authorization_request.contact_metier.email).to match(/metier\d+@/)
    end
  end

  context 'when event is send_application or submit' do
    let(:datapass_webhook_params) { build(:datapass_webhook, event: %w[send_application submit].sample, fired_at:, authorization_request_attributes: { id: authorization_id }) }

    let!(:authorization_request) { create(:authorization_request, external_id: authorization_id, first_submitted_at:) }

    context 'when first_submitted_at is nil' do
      let(:first_submitted_at) { nil }

      it 'updates it' do
        expect {
          subject
        }.to change { authorization_request.reload.first_submitted_at.to_i }.to(fired_at)
      end
    end

    context 'when first_submitted_at is present' do
      let(:first_submitted_at) { 3.days.ago }

      it 'does not update it' do
        expect {
          subject
        }.not_to change { authorization_request.reload.first_submitted_at.to_i }
      end
    end
  end

  context 'when event is validate_application or validate' do
    let(:datapass_webhook_params) { build(:datapass_webhook, event: %w[validate_application validate].sample, fired_at:, authorization_request_attributes: { id: authorization_id }) }

    let!(:authorization_request) { create(:authorization_request, external_id: authorization_id) }

    it 'sets validated_at' do
      expect {
        subject
      }.to change { authorization_request.reload.validated_at.to_i }.to(fired_at)
    end
  end
end
