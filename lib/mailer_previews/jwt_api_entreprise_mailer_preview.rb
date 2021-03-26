# @see https://guides.rubyonrails.org/action_mailer_basics.html#previewing-emails
class JwtApiEntrepriseMailerPreview < ActionMailer::Preview
  # @see http://localhost:3000/rails/mailers/jwt_api_entreprise_mailer/satisfaction_survey
  def satisfaction_survey
    token_owner_email = 'bob@gmail.com'
    token_authorization_request_id = 42

    JwtApiEntrepriseMailer.satisfaction_survey(token_owner_email, token_authorization_request_id)
  end
end
