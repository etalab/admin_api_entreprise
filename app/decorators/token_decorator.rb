class TokenDecorator < ApplicationDecorator
  delegate_all

  def attestations_scopes
    scopes.select { |scope| attestations_codes.include? scope }
  end

  def include_attestation_sociale?
    attestations_scopes.include? 'attestations_sociales'
  end

  def include_attestation_fiscale?
    attestations_scopes.include? 'attestations_fiscales'
  end

  private

  def attestations_codes
    %w[attestations_sociales attestations_fiscales]
  end
end
