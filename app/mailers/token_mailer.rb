class TokenMailer < ApplicationMailer
  include FriendlyDateHelper

  def magic_link(magic_link)
    @magic_link_url = Rails.configuration.token_magic_link_url + magic_link.access_token
    @tokens = magic_link.tokens
    @expires_at = friendly_format_from_timestamp(magic_link.expires_at)

    to = magic_link.email
    subject = t('.subject')

    mail(to:, subject:)
  end
end
