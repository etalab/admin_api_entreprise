class UserMailer < ApplicationMailer
  def renew_account_password(user)
    subject = 'API Entreprise - Mise à jour de votre mot de passe'
    @renew_pwd_url = Rails.configuration.renew_password_url.to_s + "?token=#{user.pwd_renewal_token}"

    mail(to: user.email, subject: subject)
  end

  def transfer_ownership(old_owner, new_owner)
    @new_owner = new_owner
    @old_owner = old_owner
    @login_url = 'https://dashboard.entreprise.api.gouv.fr/login'
    @datapass_signup_url = 'https://auth.api.gouv.fr/users/sign-up'
    subject = 'API Entreprise - Délégation d\'accès'

    mail(to: @new_owner.email, subject: subject)
  end

  def notify_datapasss_for_data_reconciliation(user)

  end
end
