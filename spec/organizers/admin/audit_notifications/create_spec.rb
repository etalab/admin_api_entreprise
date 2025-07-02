require 'rails_helper'

RSpec.describe Admin::AuditNotifications::Create, type: :organizer do
  describe '.call' do
    subject { described_class.call(audit_notification_params: params) }

    let!(:organization) { create(:organization, :with_insee_payload, siret: '13002526500013') }
    let(:authorization_request) { create(:authorization_request, :with_demandeur, siret: '13002526500013') }
    let(:token) { create(:token, authorization_request: authorization_request) }
    let(:first_audit_log) { create(:access_log, token: token) }
    let(:second_access_log) { create(:access_log, token: token) }

    let(:params) do
      {
        authorization_request_external_id: authorization_request.external_id,
        request_id_access_logs_input: "#{first_audit_log.request_id}\n#{second_access_log.request_id}",
        approximate_volume: 1000,
        reason: 'investigation'
      }
    end

    context 'when all parameters are valid' do
      it { is_expected.to be_a_success }

      it 'creates an audit notification' do
        expect { subject }.to change(AuditNotification, :count).by(1)
      end

      it 'sets the correct attributes on the audit notification' do
        subject

        audit_notification = AuditNotification.last
        expect(audit_notification.authorization_request_external_id).to eq(authorization_request.external_id)
        expect(audit_notification.request_id_access_logs).to contain_exactly(first_audit_log.request_id, second_access_log.request_id)
        expect(audit_notification.reason).to eq('investigation')
        expect(audit_notification.contact_emails).to include(authorization_request.demandeur.email)
      end

      it 'sends an audit email' do
        ActiveJob::Base.queue_adapter = :inline

        expect {
          subject
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        ActiveJob::Base.queue_adapter = :test
      end

      it 'makes the audit notification available in context' do
        expect(subject.audit_notification).to be_persisted
        expect(subject.audit_notification).to be_an_instance_of(AuditNotification)
      end
    end

    context 'when authorization request does not exist' do
      let(:params) do
        {
          authorization_request_external_id: 'non-existent-id',
          request_id_access_logs_input: first_audit_log.request_id.to_s,
          reason: 'investigation'
        }
      end

      it { is_expected.to be_a_failure }

      it 'does not create an audit notification' do
        expect { subject }.not_to change(AuditNotification, :count)
      end

      it 'does not send an email' do
        expect(APIEntreprise::AuditMailer).not_to receive(:with)
        subject
      end
    end

    context 'when access logs belong to different authorization request' do
      let(:other_token) { create(:token) }
      let(:other_access_log) { create(:access_log, token: other_token) }

      let(:params) do
        {
          authorization_request_external_id: authorization_request.external_id,
          request_id_access_logs_input: "#{first_audit_log.request_id}\n#{other_access_log.request_id}",
          reason: 'investigation'
        }
      end

      it { is_expected.to be_a_failure }

      it 'does not create an audit notification' do
        expect { subject }.not_to change(AuditNotification, :count)
      end

      it 'does not send an email' do
        expect(APIEntreprise::AuditMailer).not_to receive(:with)
        subject
      end
    end
  end
end
