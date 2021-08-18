# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::ScheduleAuthorizationRequestEmails, type: :interactor do
  include ActiveJob::TestHelper

  subject do
    described_class.call(
      datapass_webhook_params.merge(
        authorization_request: authorization_request,
        mailjet_variables: mailjet_variables,
      )
    )
  end

  let(:datapass_webhook_params) { build(:datapass_webhook, event: event) }
  let(:authorization_request) { create(:authorization_request, :with_contacts) }
  let(:mailjet_variables) { { lol: 'oki' } }

  before do
    Timecop.freeze
  end

  after do
    Timecop.return

    clear_enqueued_jobs
  end

  describe 'with an event which does not trigger email' do
    let(:event) { 'created' }

    it 'does not call schedule emails' do
      subject

      expect(ScheduleAuthorizationRequestMailjetEmailJob).not_to have_been_enqueued
    end
  end

  context 'with an event which trigger emails, no conditions, a when key and no attributes on recipients' do
    let(:event) { 'send_application' }

    it 'schedules emails according to configuration, to authorization request\'s user' do
      subject

      expect(ScheduleAuthorizationRequestMailjetEmailJob).to have_been_enqueued.exactly(:twice)

      expect(ScheduleAuthorizationRequestMailjetEmailJob).to have_been_enqueued.exactly(:once).with(
        authorization_request.id,
        authorization_request.status,
        hash_including(
          template_id: '11',
          to: [
            {
              'email' => authorization_request.user.email,
              'full_name' => authorization_request.user.full_name,
            },
          ],
        )
      ).at(Time.now)

      expect(ScheduleAuthorizationRequestMailjetEmailJob).to have_been_enqueued.exactly(:once).with(
        authorization_request.id,
        authorization_request.status,
        hash_including(
          template_id: '12',
          to: [
            {
              'email' => authorization_request.user.email,
              'full_name' => authorization_request.user.full_name,
            },
          ],
        )
      ).at(14.days.from_now)
    end
  end

  context 'with an event which trigger emails, conditions and recipients attributes' do
    let(:event) { 'validate_application' }

    context 'when all conditions are met' do
      before do
        authorization_request.user.update!(
          first_name: 'run',
          last_name: 'run',
        )
      end

      it 'schedules emails according to configuration, with valid recipients attributes' do
        subject

        expect(ScheduleAuthorizationRequestMailjetEmailJob).to have_been_enqueued.exactly(:twice)

        expect(ScheduleAuthorizationRequestMailjetEmailJob).to have_been_enqueued.exactly(:once).with(
          authorization_request.id,
          authorization_request.status,
          hash_including(
            template_id: '51',
            to: [
              {
                'email' => authorization_request.user.email,
                'full_name' => authorization_request.user.full_name,
              },
            ],
          )
        ).at(Time.now)

        expect(ScheduleAuthorizationRequestMailjetEmailJob).to have_been_enqueued.exactly(:once).with(
          authorization_request.id,
          authorization_request.status,
          hash_including(
            template_id: '52',
            to: [
              {
                'email' => authorization_request.contact_metier.email,
                'full_name' => authorization_request.contact_metier.full_name,
              },
            ],
            cc: [
              {
                'email' => authorization_request.contact_technique.email,
                'full_name' => authorization_request.contact_technique.full_name,
              },
              {
                'email' => authorization_request.user.email,
                'full_name' => authorization_request.user.full_name,
              },
            ],
          )
        ).at(Time.now)
      end
    end

    describe 'when one condition is not met' do
      before do
        authorization_request.user.update!(
          first_name: 'run',
          last_name: 'not run',
        )
      end

      it 'schedules only the valid condition' do
        subject

        expect(ScheduleAuthorizationRequestMailjetEmailJob).to have_been_enqueued.exactly(:once)

        expect(ScheduleAuthorizationRequestMailjetEmailJob).to have_been_enqueued.exactly(:once).with(
          authorization_request.id,
          authorization_request.status,
          hash_including(
            template_id: '51',
            to: [
              {
                'email' => authorization_request.user.email,
                'full_name' => authorization_request.user.full_name,
              },
            ],
          )
        ).at(Time.now)
      end
    end
  end
end
