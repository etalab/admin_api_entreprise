# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleAuthorizationRequestEmailJob do
  describe '#perform' do
    subject do
      described_class.perform_now(
        authorization_request_id,
        authorization_request_status,
        template_name,
        recipients
      )
    end

    let(:authorization_request_id) { authorization_request.id }
    let(:authorization_request_status) { 'draft' }

    let(:authorization_request) { create(:authorization_request, status: authorization_request_status) }
    let(:to_user) { create(:user, :with_full_name) }

    let(:template_name) { 'email_template' }
    let(:vars) { {} }

    let(:recipients) do
      {
        to: [
          {
            email: to_user.email,
            full_name: to_user.full_name
          }
        ]
      }
    end

    before(:all) do
      class APIEntreprise::AuthorizationRequestMailer
        def email_template; end
      end
    end

    context 'when authorization request does not exist' do
      let(:authorization_request_id) { 'invalid' }

      it 'does nothing' do
        expect(APIEntreprise::AuthorizationRequestMailer).not_to receive(:email_template)

        subject
      end
    end

    context 'when current authorization request status is different from authorization_request_status' do
      before do
        authorization_request.update!(
          status: 'validated'
        )
      end

      it 'does nothing' do
        expect(APIEntreprise::AuthorizationRequestMailer).not_to receive(:email_template)

        subject
      end
    end

    context 'when current authorization request status did not changed but has the old nomenclature' do
      before do
        authorization_request.update!(
          status: 'pending'
        )
      end

      it 'calls AuthorizationRequestMailer with valid params' do
        expect(APIEntreprise::AuthorizationRequestMailer).to receive(:email_template).with(
          {
            to: [{ email: to_user.email, full_name: to_user.full_name }]
          }
        )

        subject
      end
    end

    context 'when current authorization request status did not change' do
      it 'calls AuthorizationRequestMailer with valid params' do
        expect(APIEntreprise::AuthorizationRequestMailer).to receive(:email_template).with(
          {
            to: [{ email: to_user.email, full_name: to_user.full_name }]
          }
        )

        subject
      end
    end
  end
end
