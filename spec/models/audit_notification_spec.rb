require 'rails_helper'

RSpec.describe AuditNotification do
  it 'has a valid factory' do
    expect(build(:audit_notification)).to be_valid
  end

  describe 'custom validations' do
    let(:authorization_request) { create(:authorization_request) }
    let(:token) { create(:token, authorization_request: authorization_request) }
    let(:access_log) { create(:access_log, token: token) }
    let(:other_access_log) { create(:access_log) }

    describe '#validate_authorization_request_exists' do
      context 'when authorization request does not exist' do
        subject do
          build(:audit_notification,
            authorization_request_external_id: 'non-existent-id')
        end

        it 'is invalid' do
          expect(subject).not_to be_valid
        end
      end
    end

    describe '#validate_access_logs_belong_to_authorization_request' do
      context 'when all access logs belong to the authorization request' do
        subject do
          build(:audit_notification,
            authorization_request_external_id: authorization_request.external_id,
            request_id_access_logs: [access_log.request_id])
        end

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'when some access logs do not belong to the authorization request' do
        subject do
          build(:audit_notification,
            authorization_request_external_id: authorization_request.external_id,
            request_id_access_logs: [access_log.request_id, other_access_log.request_id])
        end

        it 'is invalid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:request_id_access_logs]).to be_present
        end
      end
    end
  end
end
