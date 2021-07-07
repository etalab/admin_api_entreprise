class JwtApiEntrepriseMailer < ApplicationMailer
  def expiration_notice(jwt, nb_days)
    @jwt = jwt
    @nb_days = nb_days
    recipients = @jwt.user_and_contacts_email
    subject = "API Entreprise - Votre jeton expire dans #{@nb_days} jours !"

    mail(to: recipients, subject: subject)
  end

  # TODO To remove when no more JWT issued from DS
  def expiration_notice_old(jwt, nb_days)
    @jwt = jwt
    @nb_days = nb_days
    recipients = @jwt.user_and_contacts_email
    subject = "API Entreprise - Votre jeton expire dans #{@nb_days} jours !"

    mail(to: recipients, subject: subject)
  end

  def creation_notice(new_token)
    @url_to_jwt = Rails.configuration.account_tokens_list_url.to_s
    @jwt = new_token
    recipients = @jwt.user_and_contacts_email
    subject = 'API Entreprise - Création d\'un nouveau token'

    mail(to: recipients, subject: subject)
  end

  def satisfaction_survey(jwt)
    @jwt = jwt
    recipient = @jwt.user.email

    mail(to: recipient, subject: 'API Entreprise - Comment s\'est déroulée votre demande d\'accès ?')
  end

  def magic_link(recipient, jwt)
    @jwt = jwt
    @magic_link_url = "#{Rails.configuration.jwt_magic_link_url}?token=#{jwt.magic_link_token}"
    subject = 'API Entreprise - Lien d\'accès à votre jeton !'

    mail(to: recipient, subject: subject)
  end
end
