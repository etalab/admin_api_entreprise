class TokenMailer < ApplicationMailer
  include FriendlyDateHelper

  def magic_link(magic_link, host)
    @magic_link = magic_link
    @host = host
    @entreprise_or_particulier = host.split('.').first.capitalize

    to = magic_link.email
    subject = t('.subject', api: @api = host.split('.').first.capitalize)

    mail(to:, subject:)
  end
end
