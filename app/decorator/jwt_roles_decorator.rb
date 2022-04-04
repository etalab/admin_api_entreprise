class JwtRolesDecorator
  attr_reader :jwt

  def initialize(jwt_id:)
    @jwt = JwtAPIEntreprise.find(jwt_id)
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

  def self.best_jwt_to_retrieve_attestations(jwts)
    jwts.max_by { |jwt| new(jwt_id: jwt.id).attestations_roles }
  end

  private

  def attestations_codes
    %w[attestations_sociales attestations_fiscales]
  end
end
