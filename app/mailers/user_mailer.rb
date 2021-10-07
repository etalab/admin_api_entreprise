class UserMailer < ApplicationMailer
  def transfer_ownership(old_owner, new_owner)
    @new_owner = new_owner
    @old_owner = old_owner
    @login_url = 'https://dashboard.entreprise.api.gouv.fr/login'
    @datapass_signup_url = 'https://auth.api.gouv.fr/users/sign-up'
    subject = 'API Entreprise - Délégation d\'accès'

    mail(to: @new_owner.email, subject: subject)
  end

  def notify_datapass_for_data_reconciliation(user)
    @user = user
    @authorization_requests_ids = user.jwt_api_entreprise.pluck(:authorization_request_id).map(&:to_i)
    dest_address = 'contact@api.gouv.fr'
    subject = 'API Entreprise - Réconciliation de demandes d\'accès à un nouvel usager'

    mail(to: dest_address, subject: subject)
  end
end
