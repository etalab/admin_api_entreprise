class AttestationPolicy < ApplicationPolicy
  def any?
    any_token_with_attestation_scopes?
  end

  private

  def any_token_with_attestation_scopes?
    user.tokens.flat_map { |token| attestations_scope_service.attestations_scopes(token) }.any?
  end

  def attestations_scope_service
    @attestations_scope_service ||= AttestationsScopeService.new
  end
end
