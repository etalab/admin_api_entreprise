require 'rails_helper'

RSpec.describe JwtApiEntreprise::Operation::AccessRequestSatisfactionSurvey do
  subject(:operation) { described_class }

  let!(:token) { create(:jwt_api_entreprise, datetime_of_issue, sent_state) }

  context 'when the waiting time is not reached' do
    let(:datetime_of_issue) { :less_than_seven_days_ago }

    context 'when the mail is not sent' do
      let(:sent_state) { :access_request_survey_not_sent }

      it 'does not send any email to token owners' do
        expect {
          operation.call
        }.not_to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
      end
    end

    context 'when the mail is sent' do
      let(:sent_state) { :access_request_survey_sent }

      it 'does not send any email to token owners' do
        expect {
          operation.call
        }.not_to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
      end
    end
  end

  context 'when the waiting time is reached' do
    let(:datetime_of_issue) { :about_seven_days_ago }

    context 'when the mail is not sent' do
      let(:sent_state) { :access_request_survey_not_sent }

      it 'sends an email to token owners' do
        expect {
          operation.call
        }.to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey).with(args: [token.id, token.user.email, token.authorization_request_id])
      end
    end

    context 'when the mail is sent' do
      let(:sent_state) { :access_request_survey_sent }

      it 'does not send any email to token owners' do
        expect {
          operation.call
        }.not_to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
      end
    end
  end
end
