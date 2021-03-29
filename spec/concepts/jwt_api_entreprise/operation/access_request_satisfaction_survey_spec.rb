require 'rails_helper'

RSpec.describe JwtApiEntreprise::Operation::AccessRequestSatisfactionSurvey do
  subject(:operation) { described_class }

  before do
    expect(JwtApiEntreprise).to receive(:satisfaction_survey_eligible_tokens).and_call_original
  end

  let!(:token) do
    create(:jwt_api_entreprise, :about_seven_days_ago)
  end

  let!(:token_owner_email) do
    token.user.email
  end

  let!(:token_authorization_request_id) do
    token.authorization_request_id
  end

  it 'sends an email' do
    expect {
      operation.call
    }.to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey).with(args: [token_owner_email, token_authorization_request_id])
  end
end
