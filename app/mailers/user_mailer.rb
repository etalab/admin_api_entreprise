class UserMailer < ApplicationMailer
  default from: 'no-reply@entreprise.api.gouv.fr'
  layout 'mailer'

  def confirm_account_action(user)
    subject = 'API Entreprise - Activation de compte utilisateur'

    @user = user
    @confirmation_url = Rails.configuration.account_confirmation_url.to_s + "?confirmation_token=#{@user.confirmation_token}"
    mail(to: @user.email, subject: subject)
  end

  def confirm_account_notice(user)
    @user = user
    subject = 'API Entreprise - Activation de compte utilisateur'

    recipients = user.contacts.pluck(:email).uniq
    recipients.delete user.email

    mail(to: recipients, subject: subject)
  end
end
