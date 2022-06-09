require 'rails_helper'

RSpec.describe Token::SendExpirationNotices, type: :organizer do
  describe 'expire_in: option (provide a number of days)' do
    subject { described_class.call(expire_in: days) }

    let(:days) { 90 }
    let!(:token_1) { create(:token, :expiring_within_3_month) }
    let!(:token_2) { create(:token, :expiring_within_3_month) }
    let!(:token_3) { create(:token, :expiring_in_1_year) }

    it { is_expected.to be_success }

    it 'calls the mailer for the affected JWT only' do
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(token_1, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(token_2, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(token_3, days).and_call_original

      subject
    end

    it 'does not send the same notification twice' do
      described_class.call(expire_in: days)
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(token_1, days)
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(token_2, days)

      subject
    end

    it 'does not call the mailer for archived JWTs' do
      archived_token = create(:token, :expiring_within_3_month, archived: true)
      # Expectations for sent notifications are needed, otherwise the code runs against the "dumb" double
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(token_1, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(token_2, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(archived_token, days)

      subject
    end

    it 'does not call the mailer for blacklisted JWTs' do
      blacklisted_token = create(:token, :expiring_within_3_month, blacklisted: true)
      # Expectations for sent notifications are needed, otherwise the code runs against the "dumb" double
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(token_1, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).to receive(:perform_later).with(token_2, days).and_call_original
      expect(ScheduleExpirationNoticeMailjetEmailJob).not_to receive(:perform_later).with(blacklisted_token, days)

      subject
    end

    it 'saves that the notification has been sent' do
      subject
      token_1.reload
      token_2.reload

      expect([token_1, token_2]).to all(have_attributes(days_left_notification_sent: a_collection_including(days)))
    end
  end
end
