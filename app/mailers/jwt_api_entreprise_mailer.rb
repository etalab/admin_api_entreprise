class JwtApiEntrepriseMailer < ApplicationMailer
  def expiration_notice(jwt, nb_days)
    @jwt = jwt
    @nb_days = nb_days
    recipients = @jwt.all_contacts_email
    subject = "API Entreprise - Votre jeton expire dans #{@nb_days} jours !"

    mail(to: recipients, subject: subject)
  end

  def creation_notice(new_token)
    @url_to_jwt = Rails.configuration.account_tokens_list_url.to_s % [new_token.user.id]
    @jwt = new_token
    recipients = @jwt.all_contacts_email
    subject = 'API Entreprise - Création d\'un nouveau token'

    mail(to: recipients, subject: subject)
  end
end
