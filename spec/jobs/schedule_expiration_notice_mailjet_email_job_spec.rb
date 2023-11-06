require 'rails_helper'

RSpec.describe ScheduleExpirationNoticeMailjetEmailJob do
  describe '#perform' do
    subject do
      described_class.perform_now(
        token_id,
        expires_in
      )
    end

    let(:expires_in) { 90 }
    let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique) }
    let(:token) { create(:token, authorization_request:) }
    let(:demandeur) { token.authorization_request.demandeur }
    let(:contact) { token.authorization_request.contact_technique }
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

    context 'when token is found and expires_in is valid' do
      let(:external_id) { '9001' }

      before do
        token.authorization_request.update!(external_id:)
      end

      it 'calls Mailjet client with valid params' do
        expect(Mailjet::Send).to receive(:create).with(
          {
            from_name: 'API Entreprise',
            from_email: APIEntrepriseMailer.default_params[:from],
            to: token.users.map { |user| "#{user.full_name} <#{user.email}>" }.uniq.join(', '),
            vars: {
              cadre_utilisation_token: token.intitule,
              authorization_request_id: external_id,
              expiration_date: "#{Time.zone.at(token.exp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
            },
            'Mj-TemplateLanguage' => true,
            'Mj-TemplateID' => 3_139_223
          }.stringify_keys
        )

        subject
      end

      context 'when token is for API Particulier' do
        let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique, api: 'particulier') }

        it 'calls Mailjet client with valid params' do
          expect(Mailjet::Send).to receive(:create).with(
            {
              from_name: 'API Particulier',
              from_email: APIParticulierMailer.default_params[:from],
              to: token.users.map { |user| "#{user.full_name} <#{user.email}>" }.uniq.join(', '),
              vars: {
                cadre_utilisation_token: token.intitule,
                authorization_request_id: external_id,
                expiration_date: "#{Time.zone.at(token.exp).strftime('%d/%m/%Y à %Hh%M')} (heure de Paris)"
              },
              'Mj-TemplateLanguage' => true,
              'Mj-TemplateID' => 3_139_223
            }.stringify_keys
          )

          subject
        end
      end

      context 'when Mailjet raises an error' do
        let(:mailjet_error) do
          Mailjet::ApiError.new(
            code,
            body,
            nil,
            'https://api.mailjet.com/v3/send',
            params
          )
        end
        let(:code) { 418 }
        let(:body) { "I'm a teapot!" }
        let(:params) do
          {
            oki: 'lol'
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
                mailjet_error_reason: body
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
