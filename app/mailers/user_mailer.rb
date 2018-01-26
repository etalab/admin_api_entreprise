class UserMailer < ApplicationMailer
  default from: 'no-reply@entreprise.api.gouv.fr'
  layout 'mailer'

  def confirmation_request(user)
    @user = user
    subject = 'API Entreprise - Activation de compte utilisateur'

    mail(to: @user.email, subject: subject)
  end
end
