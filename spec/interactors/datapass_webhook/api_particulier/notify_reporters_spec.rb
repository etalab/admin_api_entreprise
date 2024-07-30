RSpec.describe DatapassWebhook::APIParticulier::NotifyReporters, type: :interactor do
  include ActiveJob::TestHelper

  subject { described_class.call(datapass_webhook_params) }

  let(:datapass_webhook_params) do
    build(:datapass_webhook,
      event:,
      authorization_request_attributes: {
        scopes:
      })
  end
  let(:event) { 'approve' }
  let(:scopes) { { 'cnaf_quotient_familial' => true } }

  describe 'reporters notification' do
    describe 'when it is a submit event' do
      let(:event) { 'submit' }

      context 'when authorization request has scopes from reporters group' do
        let(:scopes) { { 'cnaf_quotient_familial' => true } }

        it { is_expected.to be_success }

        it 'notifies reporters' do
          expect {
            perform_enqueued_jobs do
              subject
            end
          }.to change { ActionMailer::Base.deliveries.count }.by(1)

          mail = ActionMailer::Base.deliveries.last

          expect(mail.subject).to match(/Une nouvelle demande a été déposé pour API Particulier/)
        end

        context 'when authorization request has no scopes from reporters group' do
          let(:scopes) { { 'cnaf_quotient_familial' => false, 'whatever' => true } }

          it { is_expected.to be_success }

          it 'does not notify reporters' do
            expect {
              perform_enqueued_jobs do
                subject
              end
            }.not_to change { ActionMailer::Base.deliveries.count }
          end
        end
      end
    end
  end
end
