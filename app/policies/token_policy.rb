class TokenPolicy < ApplicationPolicy
  attr_reader :user, :token

  def initialize(user, token)
    @user = user
    @token = token
  end

  def ask_for_prolongation?
    !demandeur? && token.day_left < 90
  end

  def show?
    demandeur? || contact_technique?
  end

  def prolong?
    demandeur? && token.day_left < 90
  end

  def attestations_scopes?
    (demandeur? || contact_metier?) && attestations_scope_service.attestations_scopes(token).any?
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
    @authorization_request ||= @token.authorization_request
  end

  def attestations_scope_service
    @attestations_scope_service ||= AttestationsScopeService.new
  end
end
