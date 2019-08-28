class JwtApiEntrepriseMailer < ApplicationMailer
  default from: 'tech@entreprise.api.gouv.fr'
  layout 'mailer'

  def expiration_notice(jwt)
    mail(to: jwt.user.email)
  end
end
