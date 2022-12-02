class TokenMailer < ApplicationMailer
  include FriendlyDateHelper

  def magic_link(magic_link, host)
    @magic_link = magic_link
    @host = host
    @namespace = host.split('.').first

    to = magic_link.email
    subject = t(".#{@namespace}.subject")

    mail(to:, subject:)
  end
end
