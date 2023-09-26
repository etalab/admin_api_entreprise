# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::ScheduleAuthorizationRequestEmails, type: :interactor do
  include ActiveJob::TestHelper

  subject do
    described_class.call(
      datapass_webhook_params.merge(
        authorization_request:
      )
    )
  end

  let(:datapass_webhook_params) { build(:datapass_webhook, event:) }
  let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_metier, :with_contact_technique) }

  before do
    Timecop.freeze(Time.new(2021, 9, 1, 12).in_time_zone)
  end

  after do
    Timecop.return

    clear_enqueued_jobs
  end

  describe 'with an event which does not trigger email' do
    let(:event) { %w[created create].sample }

    it 'does not call schedule emails' do
      subject

      expect(ScheduleAuthorizationRequestEmailJob).not_to have_been_enqueued
    end
  end

  context 'with an event which trigger emails, no conditions, a when key and no attributes on recipients' do
    let(:event) { %w[send_application submit].sample }

    it 'schedules emails according to configuration, to authorization request\'s user' do
      subject

      expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:twice)

      expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:once).with(
        authorization_request.id,
        authorization_request.status,
        hash_including(
          template_name: 'send_application',
          to: [
            {
              'email' => authorization_request.demandeur.email,
              'full_name' => authorization_request.demandeur.full_name
            }
          ]
        )
      ).at(Time.zone.now)

      expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:once).with(
        authorization_request.id,
        authorization_request.status,
        'send_application_later',
        hash_including(
          to: [
            {
              'email' => authorization_request.demandeur.email,
              'full_name' => authorization_request.demandeur.full_name
            }
          ]
        )
      ).at(14.days.from_now)
    end
  end

  context 'with an event which trigger emails, conditions and recipients attributes' do
    let(:event) { %w[refuse_application refuse].sample }

    before do
      AuthorizationRequestConditionFacade.define_method(:demandeur_first_name_is_run?) do
        demandeur.first_name == 'run'
      end

      AuthorizationRequestConditionFacade.define_method(:demandeur_last_name_is_run?) do
        demandeur.last_name == 'run'
      end
    end

    after do
      AuthorizationRequestConditionFacade.remove_method(:demandeur_first_name_is_run?)
      AuthorizationRequestConditionFacade.remove_method(:demandeur_last_name_is_run?)
    end

    describe 'when one condition is not met' do
      before do
        authorization_request.demandeur.update!(
          first_name: 'run',
          last_name: 'not run'
        )
      end

      it 'schedules only the valid condition' do
        subject

        expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:once)

        expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:once).with(
          authorization_request.id,
          authorization_request.status,
          hash_including(
            template_name: 'review_application',
            to: [
              {
                'email' => authorization_request.demandeur.email,
                'full_name' => authorization_request.demandeur.full_name
              }
            ]
          )
        ).at(Time.zone.now)
      end
    end

    context 'when all conditions are met' do
      context 'when on API Entreprise' do
        before do
          authorization_request.demandeur.update!(
            first_name: 'run',
            last_name: 'run'
          )
        end

        it 'schedules emails according to configuration, with valid recipients attributes' do
          subject

          expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:twice)

          expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:once).with(
            authorization_request.id,
            authorization_request.status,
            hash_including(
              template_name: 'review_application',
              to: [
                {
                  'email' => authorization_request.demandeur.email,
                  'full_name' => authorization_request.demandeur.full_name
                }
              ]
            )
          ).at(Time.zone.now)

          expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:once).with(
            authorization_request.id,
            authorization_request.status,
            hash_including(
              template_name: 'review_application_2',
              to: [
                {
                  'email' => authorization_request.contact_metier.email,
                  'full_name' => authorization_request.contact_metier.full_name
                }
              ],
              cc: [
                {
                  'email' => authorization_request.contact_technique.email,
                  'full_name' => authorization_request.contact_technique.full_name
                },
                {
                  'email' => authorization_request.demandeur.email,
                  'full_name' => authorization_request.demandeur.full_name
                }
              ]
            )
          ).at(Time.zone.now)
        end

        describe 'non-regression test: on an authorization_request with no contacts' do
          let(:authorization_request) { create(:authorization_request, :with_demandeur) }

          it 'do not error' do
            expect { subject }.not_to raise_error
          end
        end
      end

      context 'when on API Particulier' do
        let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique, api: 'particulier') }

        before do
          authorization_request.demandeur.update!(
            first_name: 'run',
            last_name: 'run'
          )
        end

        it 'schedules emails according to configuration, with valid recipients attributes' do
          subject

          expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:twice)

          expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:once).with(
            authorization_request.id,
            authorization_request.status,
            hash_including(
              template_name: 'review_application',
              to: [
                {
                  'email' => authorization_request.demandeur.email,
                  'full_name' => authorization_request.demandeur.full_name
                }
              ]
            )
          ).at(Time.zone.now)

          expect(ScheduleAuthorizationRequestEmailJob).to have_been_enqueued.exactly(:once).with(
            authorization_request.id,
            authorization_request.status,
            'review_application_2',
            hash_including(
              to: [
                {
                  'email' => authorization_request.contact_technique.email,
                  'full_name' => authorization_request.contact_technique.full_name
                }
              ]
            )
          ).at(Time.zone.now)
        end
      end
    end
  end
end
