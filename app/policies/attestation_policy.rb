class AttestationPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _attestation)
    @user = user
  end

  def any?
    any_token_with_attestation_scopes?
  end

  private

  def any_token_with_attestation_scopes?
    user.tokens.flat_map { |token| token.decorate.attestations_scopes }.any?
  end
end
