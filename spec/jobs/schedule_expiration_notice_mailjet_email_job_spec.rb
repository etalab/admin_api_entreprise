require 'rails_helper'

RSpec.describe ScheduleExpirationNoticeMailjetEmailJob, type: :job do
  describe '#perform' do
    subject do
      described_class.perform_now(
        token_id,
        expires_in
      )
    end

    let(:expires_in) { 90 }
    let(:token) { create(:jwt_api_entreprise) }
    let(:token_id) { token.id }

    context 'when token id is not found' do
      let(:token_id) { 0 }

      it 'does nothing' do
        expect(Mailjet::Send).not_to receive(:create)

        subject
      end
    end

    context 'when expires_in is not valid' do
      let(:expires_in) { 9001 }

      it 'does nothing' do
        expect(Mailjet::Send).not_to receive(:create)

        subject
      end
    end

    context 'when token has no authorization request (no user/contact)' do
      before do
        token.update!(
          authorization_request_model_id: nil,
        )
      end

      it 'does nothing' do
        expect(Mailjet::Send).not_to receive(:create)

        subject
      end
    end

    context 'when token is found and expires_in is valid' do
      let(:external_id) { '9001' }

      before do
        token.authorization_request.update!(
          external_id: external_id,
        )
      end

      it 'calls Mailjet client with valid params' do
        expect(Mailjet::Send).to receive(:create).with(
          {
            from_name: anything,
            from_email: anything,
            to: "#{token.user.full_name} <#{token.user.email}>",
            vars: {
              cadre_utilisation_token: token.subject,
              authorization_request_id: external_id,
              expiration_date: "#{Time.zone.at(token.exp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
            },
            'Mj-TemplateLanguage' => true,
            'Mj-TemplateID' => 3139223,
          }.stringify_keys
        )

        subject
      end

      context 'when Mailjet raises an error' do
        let(:mailjet_error) do
          Mailjet::ApiError.new(
            code,
            body,
            nil,
            'https://api.mailjet.com/v3/send',
            params,
          )
        end
        let(:code) { 418 }
        let(:body) { "I'm a teapot!" }
        let(:params) do
          {
            oki: 'lol',
          }
        end

        before do
          allow(Mailjet::Send).to receive(:create).and_raise(mailjet_error)
          allow(Sentry).to receive(:capture_exception)
        end

        it 'tracks error through Sentry, with context' do
          expect(Sentry).to receive(:set_context).with(
            'mailjet error',
            hash_including(
              {
                mailjet_error_code: code,
                mailjet_error_reason: body,
              }
            )
          ).and_call_original
          expect(Sentry).to receive(:capture_exception)

          begin
            subject
          rescue Mailjet::ApiError
          end
        end

        it 'raises this error (which reschedule job exponentialy)' do
          expect {
            subject
          }.to raise_error(Mailjet::ApiError)
        end
      end
    end
  end
end
