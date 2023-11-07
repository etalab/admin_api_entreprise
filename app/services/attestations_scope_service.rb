class AttestationsScopeService
  def best_token_to_retrieve_attestations(tokens)
    tokens.max_by { |token| attestations_scopes(token) }
  end

  def attestations_scopes(token)
    token.scopes.select { |scope| attestations_codes.include? scope }
  end

  def include_attestation_sociale?(token)
    attestations_scopes(token).intersect? attestation_sociale_scopes
  end

  def include_attestation_fiscale?(token)
    attestations_scopes(token).intersect? attestation_fiscale_scopes
  end

  private

  def attestation_sociale_scopes
    %w[attestations_sociales attestation_sociale_urssaf]
  end

  def attestation_fiscale_scopes
    %w[attestations_fiscales attestation_fiscale_dgfip]
  end

  def attestations_codes
    attestation_sociale_scopes + attestation_fiscale_scopes
  end
end
