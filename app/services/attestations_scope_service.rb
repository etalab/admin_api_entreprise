class AttestationsScopeService
  def best_token_to_retrieve_attestations(tokens)
    tokens.max_by { |token| attestations_scopes(token) }
  end

  def attestations_scopes(token)
    token.scopes.select { |scope| attestations_codes.include? scope }
  end

  def include_attestation_sociale?(token)
    attestations_scopes(token).include? 'attestations_sociales'
  end

  def include_attestation_fiscale?(token)
    attestations_scopes(token).include? 'attestations_fiscales'
  end

  private

  def attestations_codes
    %w[attestations_sociales attestations_fiscales]
  end
end
