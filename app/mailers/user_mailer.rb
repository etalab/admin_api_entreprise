class UserMailer < ApplicationMailer
  def confirm_account_action(user)
    subject = 'API Entreprise - Activation de compte utilisateur'
    @user = user
    @confirmation_url = Rails.configuration.account_confirmation_url.to_s + "?confirmation_token=#{@user.confirmation_token}"

    mail(to: @user.email, subject: subject)
  end

  def renew_account_password(user)
  end
end
