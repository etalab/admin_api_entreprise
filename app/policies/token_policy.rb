class TokenPolicy < ApplicationPolicy
  alias token record

  def ask_for_prolongation?
    !demandeur? && day_left < 90
  end

  def show?
    demandeur? || contact_technique?
  end

  def prolong?
    demandeur? && day_left < 90 && !token.blacklisted?
  end

  def download_attestations?
    DownloadAttestationsPolicy.new(user, token).any?
  end

  private

  def demandeur?
    authorization_request.demandeur == user
  end

  def contact_technique?
    authorization_request.contact_technique == user
  end

  def contact_metier?
    authorization_request.contact_metier == user
  end

  def authorization_request
    @authorization_request ||= token.authorization_request
  end

  def day_left
    (token.end_timestamp - Time.zone.now.to_i) / 1.day
  end
end
