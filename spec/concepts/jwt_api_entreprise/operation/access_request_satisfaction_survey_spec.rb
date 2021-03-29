require 'rails_helper'

RSpec.describe JwtApiEntreprise::Operation::AccessRequestSatisfactionSurvey do
  subject(:operation) { described_class }

  before do
    expect(JwtApiEntreprise).to receive(:satisfaction_survey_eligible_tokens).and_call_original
  end

  let!(:token) { create(:jwt_api_entreprise, iat: iat_value) }

  let(:token_id) { token.id }
  let(:token_owner_email) { token.user.email }
  let(:token_authorization_request_id) { token.authorization_request_id }

  context 'when tokens are not eligible to survey' do
    let(:iat_value) { attributes_for(:jwt_api_entreprise, :less_than_seven_days_ago).fetch(:iat) }

    it 'does not send any email to token owners' do
      expect {
        operation.call
      }.not_to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey)
    end
  end

  context 'when tokens are eligible to survey' do
    let(:iat_value) { attributes_for(:jwt_api_entreprise, :about_seven_days_ago).fetch(:iat) }

    it 'sends an email to token owners' do
      expect {
        operation.call
      }.to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey).with(args: [token_id, token_owner_email, token_authorization_request_id])
    end
  end
end
