class TokenMailerPreview < ActionMailer::Preview
  def satisfaction_survey
    token = FactoryBot.create(:token)
    TokenMailer.satisfaction_survey(token)
  end
end
