require 'rails_helper'

RSpec.describe Token::SendExpirationNotices, type: :organizer do
  describe 'expire_in: option (provide a number of days)' do
    subject { described_class.call(expire_in: days) }

    let(:days) { 90 }
    let!(:jwt_1) { create(:token, :expiring_within_3_month) }
    let!(:jwt_2) { create(:token, :expiring_within_3_month) }
    let!(:jwt_3) { create(:token, :expiring_in_1_year) }

    it { is_expected.to be_success }

    it 'calls the mailer for the affected JWT only' do
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(jwt_1, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(jwt_2, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(jwt_3, days).and_call_original

      subject
    end

    it 'does not send the same notification twice' do
      described_class.call(expire_in: days)
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(jwt_1, days)
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(jwt_2, days)

      subject
    end

    it 'does not call the mailer for archived JWTs' do
      archived_jwt = create(:token, :expiring_within_3_month, archived: true)
      # Expectations for sent notifications are needed, otherwise the code runs against the "dumb" double
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(jwt_1, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(jwt_2, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(archived_jwt, days)

      subject
    end

    it 'does not call the mailer for blacklisted JWTs' do
      blacklisted_jwt = create(:token, :expiring_within_3_month, blacklisted: true)
      # Expectations for sent notifications are needed, otherwise the code runs against the "dumb" double
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(jwt_1, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(jwt_2, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(blacklisted_jwt, days)

      subject
    end

    it 'saves that the notification has been sent' do
      subject
      jwt_1.reload
      jwt_2.reload

      expect([jwt_1, jwt_2]).to all(have_attributes(days_left_notification_sent: a_collection_including(days)))
    end
  end
end
