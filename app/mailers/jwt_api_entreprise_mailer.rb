class JwtApiEntrepriseMailer < ApplicationMailer
  def expiration_notice(jwt)
    mail(to: jwt.user.email)
  end
end
