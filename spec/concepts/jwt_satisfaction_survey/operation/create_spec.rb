require 'rails_helper'

RSpec.describe JwtSatisfactionSurvey::Operation::Create do
  subject(:operation) { described_class }

  before do
    expect(JwtApiEntreprise).to receive(:seven_days_ago_created_tokens).and_call_original
  end

  let!(:token_owner_email) do
    create(:jwt_api_entreprise, :about_seven_days_ago).user.email
  end

  it 'sends an email' do
    expect {
      operation.call
    }.to have_enqueued_mail(JwtApiEntrepriseMailer, :satisfaction_survey).with(args: [token_owner_email])
  end
end
