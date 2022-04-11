class EntrepriseWithAttestationsFacade
  def initialize(jwt:, siret:)
    @siret = siret
    @siade_client = Siade.new(token: jwt)

    preload_available_endpoints(jwt)
  end

  def preload_available_endpoints(jwt)
    entreprise

    jwt_roles = jwt.decorate.roles

    attestation_sociale_url if jwt_roles.include? 'attestations_sociales'
    attestation_fiscale_url if jwt_roles.include? 'attestations_fiscales'
  end

  def attestation_sociale_url
    @attestation_sociale_url ||= @siade_client.attestations_sociales(siren:)['url']
  end

  def attestation_fiscale_url
    @attestation_fiscale_url ||= @siade_client.attestations_fiscales(siren:)['url']
  end

  def entreprise
    entreprise_interesting_keys = entreprise_payload.slice(
      :raison_sociale, :naf_entreprise, :libelle_naf_entreprise, :forme_juridique, :categorie_entreprise
    )

    @entreprise ||= Entreprise.new(entreprise_interesting_keys)
  end

  def entreprise_payload
    response = @siade_client.entreprises(siren:)

    response['entreprise'].transform_keys(&:to_sym)
  end

  def entreprise_naf_full
    "#{entreprise.naf_entreprise} - #{entreprise.libelle_naf_entreprise}"
  end

  delegate :raison_sociale, :forme_juridique, to: :entreprise, prefix: true
  delegate :categorie_entreprise, to: :entreprise

  def siren
    @siret.first(9)
  end
end
