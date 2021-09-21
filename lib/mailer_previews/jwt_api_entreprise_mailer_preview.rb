class JwtAPIEntrepriseMailerPreview < ActionMailer::Preview
  def satisfaction_survey
    token = FactoryBot.create(:jwt_api_entreprise)
    JwtAPIEntrepriseMailer.satisfaction_survey(token)
  end
end
