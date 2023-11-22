require 'rails_helper'

RSpec.describe ScheduleExpirationNoticeEmailJob do
  describe '#perform' do
    subject do
      described_class.perform_now(token_id, expires_in)
    end

    let(:expires_in) { 90 }
    let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique) }
    let(:token) { create(:token, authorization_request:) }
    let(:token_id) { token.id }

    context 'when token id is not found' do
      let(:token_id) { 0 }

      it 'does nothing' do
        expect { subject }.not_to have_enqueued_mail(APIEntreprise::TokenMailer)

        subject
      end
    end

    context 'when expires_in is not valid' do
      let(:expires_in) { 9001 }

      it 'does nothing' do
        expect { subject }.not_to have_enqueued_mail(APIEntreprise::TokenMailer)

        subject
      end
    end

    context 'when token is found and expires_in is valid' do
      let(:external_id) { '9001' }

      before do
        token.authorization_request.update!(external_id:)
      end

      it 'sends the correct mail' do
        expect { subject }.to have_enqueued_mail(APIEntreprise::TokenMailer, :expiration_notice_90J).with(token:)

        subject
      end
    end

    context 'when token is expired' do
      let(:expires_in) { 0 }

      it 'sends the correct mail' do
        expect { subject }.to have_enqueued_mail(APIEntreprise::TokenMailer, :expiration_notice_0J).with(token:)

        subject
      end
    end
  end
end
