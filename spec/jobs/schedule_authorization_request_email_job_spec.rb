# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleAuthorizationRequestEmailJob do
  describe '#perform' do
    subject do
      described_class.perform_now(
        authorization_request_id,
        authorization_request_status,
        mail_attributes
      )
    end

    let(:authorization_request_id) { authorization_request.id }
    let(:authorization_request_status) { 'draft' }

    let(:authorization_request) { create(:authorization_request, status: authorization_request_status) }
    let(:to_user) { create(:user, :with_full_name) }

    let(:template_name) { 'email_template' }
    let(:vars) { {} }

    let(:mail_attributes) do
      {
        template_name:,
        vars:,
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

      context 'when there is cc field in attributes' do
        let(:cc_contact_main) { create(:user, :with_full_name) }
        let(:cc_contact_other) { create(:user, :with_full_name) }

        before do
          mail_attributes[:cc] = [
            {
              email: cc_contact_main.email,
              full_name: cc_contact_main.full_name
            },
            {
              email: cc_contact_other.email,
              full_name: cc_contact_other.full_name
            }
          ]
        end

        it 'calls AuthorizationRequestMailer with the CC field for these users' do
          expect(APIEntreprise::AuthorizationRequestMailer).to receive(:email_template).with(
            {
              to: [{ email: to_user.email, full_name: to_user.full_name }],
              cc: [
                { email: cc_contact_main.email, full_name: cc_contact_main.full_name },
                { email: cc_contact_other.email, full_name: cc_contact_other.full_name }
              ]
            }
          )

          subject
        end
      end
    end
  end
end
