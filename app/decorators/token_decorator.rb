class TokenDecorator < ApplicationDecorator
  delegate_all

  def attestations_scopes
    scopes.select { |r| attestations_codes.include? r.code }
  end

  def include_attestation_sociale?
    attestations_scopes.map(&:code).include? 'attestations_sociales'
  end

  def include_attestation_fiscale?
    attestations_scopes.map(&:code).include? 'attestations_fiscales'
  end

  private

  def attestations_codes
    %w[attestations_sociales attestations_fiscales]
  end
end
