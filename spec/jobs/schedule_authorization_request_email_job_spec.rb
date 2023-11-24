# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleAuthorizationRequestEmailJob do
  include ActiveJob::TestHelper

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
    let(:template_name) { 'demande_recue' }

    let(:authorization_request) { create(:authorization_request, :with_demandeur, status: authorization_request_status) }
    let(:to_user) { create(:user, :with_full_name) }

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

    before do
      allow(APIEntreprise::AuthorizationRequestMailer).to receive(:demande_recue).and_call_original
    end

    context 'when authorization request does not exist' do
      let(:authorization_request_id) { 'invalid' }

      it 'does not call mailer' do
        expect(APIEntreprise::AuthorizationRequestMailer).not_to receive(:demande_recue)

        subject
      end
    end

    context 'when current authorization request status is different from authorization_request_status' do
      before do
        authorization_request.update!(
          status: 'validated'
        )
      end

      it 'does not call mailer' do
        expect(APIEntreprise::AuthorizationRequestMailer).not_to receive(:demande_recue)

        subject
      end
    end

    context 'when current authorization request status did not changed but has the old nomenclature' do
      before do
        authorization_request.update!(
          status: 'pending'
        )
      end

      it 'calls mailer with valid template name' do
        expect(APIEntreprise::AuthorizationRequestMailer).to receive(:demande_recue)

        subject
      end

      it 'delivers email' do
        expect {
          perform_enqueued_jobs do
            subject
          end
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when current authorization request status did not change' do
      it 'calls mailer with valid template name' do
        expect(APIEntreprise::AuthorizationRequestMailer).to receive(:demande_recue)

        subject
      end

      it 'delivers email' do
        expect {
          perform_enqueued_jobs do
            subject
          end
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
