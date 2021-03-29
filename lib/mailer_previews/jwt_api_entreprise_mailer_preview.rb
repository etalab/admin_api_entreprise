class JwtApiEntrepriseMailerPreview < ActionMailer::Preview
  def satisfaction_survey
    token_owner_email = 'bob@gmail.com'
    token_authorization_request_id = 42

    JwtApiEntrepriseMailer.satisfaction_survey(token_owner_email, token_authorization_request_id)
  end
end
