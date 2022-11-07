class TokenMailer < ApplicationMailer
  include FriendlyDateHelper

  def magic_link(magic_link, host)
    @magic_link = magic_link
    @host = host

    to = magic_link.email
    subject = t('.subject')

    mail(to:, subject:)
  end
end
