require 'rails_helper'

RSpec.describe Admin::AuditNotifications::CreateModel, type: :interactor do
  describe '.call' do
    subject { described_class.call(audit_notification_params: params) }

    let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique, :with_contact_metier) }
    let(:token) { create(:token, authorization_request: authorization_request) }
    let(:first_access_log) { create(:access_log, token: token) }
    let(:second_access_log) { create(:access_log, token: token) }

    let(:params) do
      {
        authorization_request_external_id: authorization_request.external_id,
        request_id_access_logs_input: "#{first_access_log.request_id}, #{second_access_log.request_id}",
        reason: 'investigation'
      }
    end

    context 'when all parameters are valid' do
      it { is_expected.to be_a_success }

      it 'creates an audit notification' do
        expect { subject }.to change(AuditNotification, :count).by(1)
      end

      it 'sets the audit notification in context' do
        subject
        expect(subject.audit_notification).to be_persisted
        expect(subject.audit_notification).to be_an_instance_of(AuditNotification)
      end

      it 'processes request IDs correctly from comma-separated input' do
        subject
        expect(subject.audit_notification.request_id_access_logs).to contain_exactly(first_access_log.request_id, second_access_log.request_id)
      end

      it 'processes request IDs correctly from newline-separated input' do
        params[:request_id_access_logs_input] = "#{first_access_log.request_id}\n#{second_access_log.request_id}"
        subject
        expect(subject.audit_notification.request_id_access_logs).to contain_exactly(first_access_log.request_id, second_access_log.request_id)
      end

      it 'removes duplicate request IDs' do
        params[:request_id_access_logs_input] = "#{first_access_log.request_id}, #{first_access_log.request_id}, #{second_access_log.request_id}"
        subject
        expect(subject.audit_notification.request_id_access_logs).to contain_exactly(first_access_log.request_id, second_access_log.request_id)
      end

      it 'strips whitespace from request IDs' do
        params[:request_id_access_logs_input] = "  #{first_access_log.request_id}  ,  #{second_access_log.request_id}  "
        subject
        expect(subject.audit_notification.request_id_access_logs).to contain_exactly(first_access_log.request_id, second_access_log.request_id)
      end

      it 'removes empty strings from request IDs' do
        params[:request_id_access_logs_input] = "#{first_access_log.request_id},,#{second_access_log.request_id}"
        subject
        expect(subject.audit_notification.request_id_access_logs).to contain_exactly(first_access_log.request_id, second_access_log.request_id)
      end

      it 'extracts contact emails from authorization request' do
        subject
        expected_emails = [
          authorization_request.demandeur.email,
          authorization_request.contact_technique.email,
          authorization_request.contact_metier.email
        ]
        expect(subject.audit_notification.contact_emails).to match_array(expected_emails)
      end
    end

    context 'when authorization request does not exist' do
      let(:params) do
        {
          authorization_request_external_id: 'non-existent-id',
          request_id_access_logs_input: first_access_log.request_id,
          reason: 'investigation'
        }
      end

      it { is_expected.to be_a_failure }

      it 'does not create an audit notification' do
        expect { subject }.not_to change(AuditNotification, :count)
      end

      it 'sets the invalid audit notification in context' do
        subject
        expect(subject.audit_notification).to be_present
        expect(subject.audit_notification).not_to be_persisted
      end
    end

    context 'when access logs belong to different authorization request' do
      let(:other_token) { create(:token) }
      let(:other_access_log) { create(:access_log, token: other_token) }

      let(:params) do
        {
          authorization_request_external_id: authorization_request.external_id,
          request_id_access_logs_input: "#{first_access_log.request_id}, #{other_access_log.request_id}",
          reason: 'investigation'
        }
      end

      it { is_expected.to be_a_failure }

      it 'does not create an audit notification' do
        expect { subject }.not_to change(AuditNotification, :count)
      end
    end

    context 'when authorization request has no contacts' do
      let(:authorization_request_no_contacts) { create(:authorization_request) }
      let(:params) do
        {
          authorization_request_external_id: authorization_request_no_contacts.external_id,
          request_id_access_logs_input: first_access_log.request_id,
          reason: 'investigation'
        }
      end

      it 'sets empty contact emails array' do
        subject
        expect(subject.audit_notification.contact_emails).to eq([])
      end
    end

    context 'when authorization request has duplicate contact emails' do
      let(:shared_email) { 'shared@example.com' }
      let(:demandeur_user) { create(:user, email: shared_email) }
      let(:contact_technique_user) { create(:user, email: "#{shared_email}.technique") }
      let(:contact_metier_user) { demandeur_user } # Same user as demandeur

      let(:authorization_request) do
        create(:authorization_request, :with_demandeur, :with_contact_technique, :with_contact_metier,
          demandeur: demandeur_user,
          contact_technique: contact_technique_user,
          contact_metier: contact_metier_user)
      end

      it 'removes duplicate emails' do
        subject
        expected_emails = [shared_email, contact_technique_user.email]
        expect(subject.audit_notification.contact_emails).to match_array(expected_emails)
      end
    end

    context 'when request_id_access_logs_input is blank' do
      let(:params) do
        {
          authorization_request_external_id: authorization_request.external_id,
          request_id_access_logs_input: '',
          reason: 'investigation'
        }
      end

      it { is_expected.to be_a_failure }

      it 'does not create an audit notification' do
        expect { subject }.not_to change(AuditNotification, :count)
      end
    end
  end
end
