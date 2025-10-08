require 'rails_helper'

RSpec.describe Admin::Tokens::Ban, type: :organizer do
  describe '.call' do
    subject { described_class.call(token:, admin:, comment:, namespace: 'entreprise') }

    let(:admin) { create(:user, :admin) }
    let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique, api: 'entreprise') }
    let!(:token) { create(:token, authorization_request:) }
    let(:comment) { nil }

    context 'when token is valid and active' do
      it { is_expected.to be_a_success }

      it 'creates a new token' do
        expect { subject }.to change(Token, :count).by(1)
      end

      it 'blacklists the original token in 30 days' do
        subject
        expect(token.reload.blacklisted_at).to be_within(1.minute).of(1.month.from_now)
      end

      it 'sets the new token iat to current time' do
        subject
        new_token = Token.where.not(id: token.id).order(created_at: :desc).first
        expect(new_token.iat).to be_within(5).of(Time.zone.now.to_i)
      end

      it 'sends emails to demandeur and contact technique' do
        expect { subject }.to have_enqueued_job(ActionMailer::MailDeliveryJob).at_least(2).times
      end

      it 'tracks the ban event' do
        expect(MonitoringService.instance).to receive(:track).with(
          'Ban token by admin',
          level: 'info',
          context: hash_including(
            admin_id: admin.id,
            token_id: token.id,
            datapass_id: token.authorization_request.external_id
          )
        )

        subject
      end

      context 'when comment is provided' do
        let(:comment) { 'Token was compromised' }

        it { is_expected.to be_a_success }

        it 'sends emails with comment included' do
          expect { subject }.to have_enqueued_job(ActionMailer::MailDeliveryJob).at_least(2).times
        end
      end
    end

    context 'when token is already blacklisted' do
      let!(:token) { create(:token, :blacklisted, authorization_request:) }

      it { is_expected.to be_a_failure }

      it 'does not create a new token' do
        initial_count = Token.count
        subject
        expect(Token.count).to eq(initial_count)
      end

      it 'does not send emails' do
        expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end

    context 'when token does not exist' do
      subject { described_class.call(token: nil, comment: nil, namespace: 'entreprise') }

      it { is_expected.to be_a_failure }

      it 'does not create a new token' do
        initial_count = Token.count
        subject
        expect(Token.count).to eq(initial_count)
      end

      it 'does not send emails' do
        expect { subject }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end

    context 'when authorization request has no contact_technique' do
      let(:authorization_request) { create(:authorization_request, :with_demandeur, api: 'entreprise') }

      it { is_expected.to be_a_success }

      it 'sends email only to demandeur' do
        expect { subject }.to have_enqueued_job(ActionMailer::MailDeliveryJob).at_least(1).times
      end
    end
  end
end
