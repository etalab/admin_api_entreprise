class JwtAPIEntrepriseDecorator
  def initialize(jwt)
    @jwt = jwt
  end

  def roles
    @jwt.roles
  end

  def attestations_roles
    roles.select { |r| attestations_codes.include? r.code }
  end

  def include_attestation_sociale?
    attestations_roles.map(&:code).include? 'attestations_sociales'
  end

  def include_attestation_fiscale?
    attestations_roles.map(&:code).include? 'attestations_fiscales'
  end

  private

  def attestations_codes
    %w[attestations_sociales attestations_fiscales]
  end
end
