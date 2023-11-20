require 'rails_helper'

RSpec.describe Token::SendExpirationNotices, type: :organizer do
  describe 'expire_in: option (provide a number of days)' do
    subject { described_class.call(expire_in: days) }

    let(:days) { 90 }
    let!(:one_token_expired_within_3_month) { create(:token, :expiring_within_3_month) }
    let!(:another_token_expired_within_3_month) { create(:token, :expiring_within_3_month) }
    let!(:token_expired_within_1_year) { create(:token, :expiring_in_1_year) }

    describe 'when API Particulier (temporary)' do
      let!(:one_token_expired_within_3_month) { create(:token, :expiring_within_3_month, :with_api_particulier) }
      let!(:another_token_expired_within_3_month) { create(:token, :expiring_within_3_month, :with_api_particulier) }
      let!(:token_expired_within_1_year) { create(:token, :expiring_in_1_year, :with_api_particulier) }

      it 'doesnt send anything' do
        expect(ScheduleExpirationNoticeEmailJob).not_to receive(:perform_later).with(one_token_expired_within_3_month, days).and_call_original
        expect(ScheduleExpirationNoticeEmailJob).not_to receive(:perform_later).with(another_token_expired_within_3_month, days).and_call_original
        expect(ScheduleExpirationNoticeEmailJob).not_to receive(:perform_later).with(token_expired_within_1_year, days).and_call_original

        subject
      end
    end

    it { is_expected.to be_success }

    it 'calls the mailer for the affected tokens only' do
      expect(ScheduleExpirationNoticeEmailJob).to receive(:perform_later).with(one_token_expired_within_3_month, days).and_call_original
      expect(ScheduleExpirationNoticeEmailJob).to receive(:perform_later).with(another_token_expired_within_3_month, days).and_call_original
      expect(ScheduleExpirationNoticeEmailJob).not_to receive(:perform_later).with(token_expired_within_1_year, days).and_call_original

      subject
    end

    it 'does not send the same notification twice' do
      described_class.call(expire_in: days)
      expect(ScheduleExpirationNoticeEmailJob).not_to receive(:perform_later).with(one_token_expired_within_3_month, days)
      expect(ScheduleExpirationNoticeEmailJob).not_to receive(:perform_later).with(another_token_expired_within_3_month, days)

      subject
    end

    it 'does not call the mailer for archived tokens' do
      authorization_request = create(:authorization_request, previous_external_id: 1234, status: 'archived')
      archived_token = create(:token, :expiring_within_3_month, authorization_request:)

      # Expectations for sent notifications are needed, otherwise the code runs against the "dumb" double
      expect(ScheduleExpirationNoticeEmailJob).to receive(:perform_later).with(one_token_expired_within_3_month, days).and_call_original
      expect(ScheduleExpirationNoticeEmailJob).to receive(:perform_later).with(another_token_expired_within_3_month, days).and_call_original
      expect(ScheduleExpirationNoticeEmailJob).not_to receive(:perform_later).with(archived_token, days)

      subject
    end

    it 'does not call the mailer for blacklisted tokens' do
      blacklisted_token = create(:token, :expiring_within_3_month, :blacklisted)
      # Expectations for sent notifications are needed, otherwise the code runs against the "dumb" double
      expect(ScheduleExpirationNoticeEmailJob).to receive(:perform_later).with(one_token_expired_within_3_month, days).and_call_original
      expect(ScheduleExpirationNoticeEmailJob).to receive(:perform_later).with(another_token_expired_within_3_month, days).and_call_original
      expect(ScheduleExpirationNoticeEmailJob).not_to receive(:perform_later).with(blacklisted_token, days)

      subject
    end

    it 'saves that the notification has been sent' do
      subject
      one_token_expired_within_3_month.reload
      another_token_expired_within_3_month.reload

      expect([one_token_expired_within_3_month, another_token_expired_within_3_month]).to all(have_attributes(days_left_notification_sent: a_collection_including(days)))
    end
  end
end
