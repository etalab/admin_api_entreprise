class JwtAPIEntrepriseMailer < ApplicationMailer
  def magic_link(recipient, jwt)
    @jwt = jwt
    @magic_link_url = Rails.configuration.jwt_magic_link_url + jwt.magic_link_token
    subject = 'API Entreprise - Lien d\'accès à votre jeton !'

    mail(to: recipient, subject: subject)
  end
end
