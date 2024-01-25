module UserMailerCommons
  include FriendlyDateHelper

  def transfer_ownership(old_owner, new_owner, namespace)
    @new_owner = new_owner
    @old_owner = old_owner
    @login_url = "https://#{api(namespace)}.api.gouv.fr/compte/se-connecter"
    @datapass_signup_url = 'https://app.moncomptepro.beta.gouv.fr/users/sign-up'
    subject = "#{I18n.t("#{namespace}.name")} - Délégation d'accès"

    mail(to: @new_owner.email, subject:)
  end

  def notify_datapass_for_data_reconciliation(user, namespace)
    @user = user
    @datapass_ids = user.authorization_requests.map(&:external_id).map(&:to_i)

    dest_address = 'datapass@api.gouv.fr'
    subject = "#{I18n.t("#{namespace}.name")} - Réconciliation de demandes d'accès à un nouvel usager"

    mail(to: dest_address, subject:)
  end

  def api(namespace)
    namespace.slice(4..-1)
  end
end
