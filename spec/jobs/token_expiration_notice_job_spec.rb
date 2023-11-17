require 'rails_helper'

RSpec.describe TokenExpirationNoticeJob do
  include ActiveJob::TestHelper

  subject { described_class.perform_now }

  shared_examples 'sending expiration notices' do |nb_days|
    it "sends notifications for token expiration in #{nb_days} days" do
      notifier_spy = class_spy(Token::SendExpirationNotices)
      stub_const('Token::SendExpirationNotices', notifier_spy)

      subject

      expect(notifier_spy).to have_received(:call).with(expire_in: nb_days)
    end
  end

  it_behaves_like 'sending expiration notices', 0
  it_behaves_like 'sending expiration notices', 7
  it_behaves_like 'sending expiration notices', 14
  it_behaves_like 'sending expiration notices', 30
  it_behaves_like 'sending expiration notices', 60
  it_behaves_like 'sending expiration notices', 90

  describe 'when there is a token with an expiration date in 7 days' do
    let!(:token) { create(:token, exp: 7.days.from_now, days_left_notification_sent:) }

    before do
      clear_enqueued_jobs
    end

    context 'when none of the expiration notice has been sent' do
      let(:days_left_notification_sent) { [] }

      it 'sent the notification for 7 days' do
        expect {
          subject
        }.to have_enqueued_job(ScheduleExpirationNoticeEmailJob).with(token, 7)
      end

      it 'only sent one email' do
        expect {
          subject
        }.to change(enqueued_jobs, :size).by(1)

        expect(token.reload.days_left_notification_sent).to eq([7])
      end
    end
  end
end
