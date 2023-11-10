class DownloadAttestationsPolicy < ApplicationPolicy
  alias token record

  def any?
    (
      demandeur? ||
        contact_metier?
    ) &&
      (
        attestation_sociale? ||
          attestation_fiscale?
      )
  end

  private

  def demandeur?
    role?('demandeur')
  end

  def contact_metier?
    role?('contact_metier')
  end

  def role?(role)
    token.authorization_request.public_send(role) == user
  rescue NoMethodError
    UserAuthorizationRequestRole.where(
      user:,
      role:
    ).any?
  end

  def attestation_sociale?
    %w[attestations_sociales attestation_sociale_urssaf].intersect?(scopes)
  end

  def attestation_fiscale?
    %w[attestations_fiscales attestation_fiscale_dgfip].intersect?(scopes)
  end

  def scopes
    token.scopes
  rescue NoMethodError
    user.tokens.map(&:scopes).flatten
  end
end
