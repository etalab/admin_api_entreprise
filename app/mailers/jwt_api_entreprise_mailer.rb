class JwtApiEntrepriseMailer < ApplicationMailer
  include ::UserHelper

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
    @url_to_jwt = Rails.configuration.account_tokens_list_url.to_s
    @jwt = jwt
    recipients = @jwt.user_and_contacts_email
    @full_name = full_name_builder(@jwt.user.first_name, @jwt.user.last_name)

    subject = if @full_name.nil?
                t('jwt_api_entreprise_mailer_satisfaction_survey_subject')
              else
                t('jwt_api_entreprise_mailer_satisfaction_survey_subject_with_full_name', full_name: @full_name)
              end

    mail(to: recipients, subject: subject)
  end
end
