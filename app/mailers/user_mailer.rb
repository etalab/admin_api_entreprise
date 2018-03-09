class UserMailer < ApplicationMailer
  default from: 'no-reply@entreprise.api.gouv.fr'
  layout 'mailer'

  def confirmation_request(user)
    subject = 'API Entreprise - Activation de compte utilisateur'

    @user = user
    @confirmation_url = Rails.configuration.account_confirmation_url.to_s + "?confirmation_token=#{@user.confirmation_token}"
    mail(to: @user.email, subject: subject)
  end
end
