class JwtApiEntrepriseMailer < ApplicationMailer
  def expiration_notice(jwt, nb_days)
    @jwt = jwt
    @nb_days = nb_days

    recipients = exp_notice_recipients
    subject = "API Entreprise - Votre jeton expire dans #{@nb_days} jours !"

    mail(to: recipients, subject: subject)
  end

  private

  def exp_notice_recipients
    # TODO: This could be better and clearer here, be patient it will be refactor soon
    main_account_email = @jwt.user.email
    business_addresses = @jwt.user.contacts.where(contact_type: 'admin').pluck(:email)
    tech_addresses = @jwt.user.contacts.where(contact_type: 'tech').pluck(:email)

    recipients = [main_account_email, business_addresses, tech_addresses]
    recipients.flatten.uniq
  end
end
