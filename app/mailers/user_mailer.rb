class UserMailer < ApplicationMailer
  include FriendlyDateHelper

  def magic_link_signin(magic_link, host)
    @magic_link = magic_link
    @host = host
    @entreprise_or_particulier = host.split('.').first.capitalize

    to = magic_link.email
    subject = t('.subject', api: @entreprise_or_particulier)

    mail(to:, subject:)
  end

  def transfer_ownership(old_owner, new_owner)
    @new_owner = new_owner
    @old_owner = old_owner
    @login_url = 'https://dashboard.entreprise.api.gouv.fr/login'
    @datapass_signup_url = 'https://auth.api.gouv.fr/users/sign-up'
    subject = 'API Entreprise - Délégation d\'accès'

    mail(to: @new_owner.email, subject:)
  end

  def notify_datapass_for_data_reconciliation(user)
    @user = user
    @authorization_requests_ids = user.tokens.pluck(:authorization_request_id).map(&:to_i)
    dest_address = 'datapass@api.gouv.fr'
    subject = 'API Entreprise - Réconciliation de demandes d\'accès à un nouvel usager'

    mail(to: dest_address, subject:)
  end
end
