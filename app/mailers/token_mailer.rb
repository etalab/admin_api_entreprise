class TokenMailer < ApplicationMailer
  def magic_link(magic_link)
    @magic_link_url = Rails.configuration.token_magic_link_url + magic_link.random_token

    to = magic_link.email
    subject = t('.subject')

    mail(to: recipient, subject:)
  end
end
