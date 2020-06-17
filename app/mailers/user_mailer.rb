class UserMailer < ApplicationMailer
  def renew_account_password(user)
    subject = 'API Entreprise - Mise à jour de votre mot de passe'
    @renew_pwd_url = Rails.configuration.renew_password_url.to_s + "?token=#{user.pwd_renewal_token}"

    mail(to: user.email, subject: subject)
  end
end
