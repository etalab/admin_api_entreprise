class JwtApiEntrepriseMailer < ApplicationMailer
  def expiration_notice(jwt, nb_days)
    @jwt = jwt
    @nb_days = nb_days

    subject = "API Entreprise - Expiration de votre jeton d'accès dans #{@nb_days} jours !"

    mail(to: jwt.user.email, subject: subject)
  end
end
