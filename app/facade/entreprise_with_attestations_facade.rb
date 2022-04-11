class EntrepriseWithAttestationsFacade
  attr_reader :entreprise, :attestation_sociale_url, :attestation_fiscale_url

  def initialize(jwt:, siret:)
    @siret = siret
    @siade_client = Siade.new(token: jwt)

    preload_available_endpoints(jwt)
  end

  def preload_available_endpoints(jwt)
    @entreprise = entreprise_result

    jwt_role_codes = jwt.decorate.roles.map(&:code)

    @attestation_sociale_url = attestation_sociale_result if jwt_role_codes.include? 'attestations_sociales'
    @attestation_fiscale_url = attestation_fiscale_result if jwt_role_codes.include? 'attestations_fiscales'
  end

  def entreprise_naf_full
    "#{entreprise.naf_entreprise} - #{entreprise.libelle_naf_entreprise}"
  end

  delegate :raison_sociale, :forme_juridique, to: :entreprise, prefix: true
  delegate :categorie_entreprise, to: :entreprise

  private

  def entreprise_result
    entreprise_interesting_keys = entreprise_payload.slice(
      :raison_sociale, :naf_entreprise, :libelle_naf_entreprise, :forme_juridique, :categorie_entreprise
    )

    Entreprise.new(entreprise_interesting_keys)
  end

  def entreprise_payload
    response = @siade_client.entreprises(siren:)

    response['entreprise'].transform_keys(&:to_sym)
  end

  def attestation_sociale_result
    @siade_client.attestations_sociales(siren:)['url']
  end

  def attestation_fiscale_result
    @siade_client.attestations_fiscales(siren:)['url']
  end

  def siren
    @siret.first(9)
  end
end
