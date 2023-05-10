# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScheduleAuthorizationRequestMailjetEmailJob do
  describe '#perform' do
    subject do
      described_class.perform_now(
        authorization_request_id,
        authorization_request_status,
        mailjet_attributes
      )
    end

    let(:authorization_request_id) { authorization_request.id }
    let(:authorization_request_status) { 'draft' }
    let(:mailjet_attributes) do
      {
        template_id: mailjet_template_id,
        vars: mailjet_template_vars,
        to: [
          {
            email: to_user.email,
            full_name: to_user.full_name
          }
        ]
      }
    end

    let(:authorization_request) { create(:authorization_request, status: authorization_request_status) }
    let(:to_user) { create(:user, :with_full_name) }
    let(:mailjet_template_id) { '1234567890' }
    let(:mailjet_template_vars) { {} }

    context 'when authorization request does not exist' do
      let(:authorization_request_id) { 'invalid' }

      it 'does nothing' do
        expect(Mailjet::Send).not_to receive(:create)

        subject
      end
    end

    context 'when current authorization request status is different from authorization_request_status' do
      before do
        authorization_request.update!(
          status: 'validated'
        )
      end

      it 'does nothing' do
        expect(Mailjet::Send).not_to receive(:create)

        subject
      end
    end

    context 'when current authorization request status did not changed but has the old nomenclature' do
      before do
        authorization_request.update!(
          status: 'pending'
        )
      end

      it 'calls Mailjet client with valid params' do
        expect(Mailjet::Send).to receive(:create).with(
          {
            from_name: anything,
            from_email: anything,
            to: "#{to_user.full_name} <#{to_user.email}>",
            vars: mailjet_template_vars,
            'Mj-TemplateLanguage' => true,
            'Mj-TemplateID' => mailjet_template_id
          }.stringify_keys
        )

        subject
      end
    end

    context 'when current authorization request status did not changed' do
      it 'calls Mailjet client with valid params' do
        expect(Mailjet::Send).to receive(:create).with(
          {
            from_name: anything,
            from_email: anything,
            to: "#{to_user.full_name} <#{to_user.email}>",
            vars: mailjet_template_vars,
            'Mj-TemplateLanguage' => true,
            'Mj-TemplateID' => mailjet_template_id
          }.stringify_keys
        )

        subject
      end

      context 'when there is cc field in mailjet attributes' do
        let(:cc_contact_main) { create(:user, :with_full_name) }
        let(:cc_contact_other) { create(:user, :with_full_name) }

        before do
          mailjet_attributes[:cc] = [
            {
              email: cc_contact_main.email,
              full_name: cc_contact_main.full_name
            },
            {
              email: cc_contact_other.email,
              full_name: cc_contact_other.full_name
            }
          ]
        end

        it 'calls Mailjet client with the CC field for these users' do
          expect(Mailjet::Send).to receive(:create).with(
            {
              from_name: anything,
              from_email: anything,
              to: "#{to_user.full_name} <#{to_user.email}>",
              cc: "#{cc_contact_main.full_name} <#{cc_contact_main.email}>, #{cc_contact_other.full_name} <#{cc_contact_other.email}>",
              vars: mailjet_template_vars,
              'Mj-TemplateLanguage' => true,
              'Mj-TemplateID' => mailjet_template_id
            }.stringify_keys
          )

          subject
        end
      end

      describe 'non-regression test: when a CC field is empty' do
        let(:cc_contact_main) { create(:user, :with_full_name) }

        before do
          mailjet_attributes[:cc] = [nil]
        end

        it 'do not error' do
          expect(Mailjet::Send).to receive(:create)

          expect { subject }.not_to raise_error
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

        it 'raises this error (which reschedule job exponentially)' do
          expect {
            subject
          }.to raise_error(Mailjet::ApiError)
        end
      end
    end
  end
end
