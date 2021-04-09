class JwtApiEntrepriseMailerPreview < ActionMailer::Preview
  def satisfaction_survey
    token = FactoryBot.create(:jwt_api_entreprise)
    JwtApiEntrepriseMailer.satisfaction_survey(token)
  end
end
