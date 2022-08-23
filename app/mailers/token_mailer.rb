class TokenMailer < ApplicationMailer
  def magic_link(recipient, token)
    @token = token
    @magic_link_url = Rails.configuration.token_magic_link_url + token.magic_link_token
    subject = t('.subject')

    mail(to: recipient, subject:)
  end
end
