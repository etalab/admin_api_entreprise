class AttestationFacade
  def initialize(jwt:, siret:)
    @siret = siret
    @siade_client = Siade.new(token_rehash: jwt.rehash)

    preload_available_endpoints(jwt)
  end

  def preload_available_endpoints(jwt)
    @entreprise = entreprise

    jwt_roles = JwtFacade.new(jwt_id: jwt.id).roles

    @attestation_sociale_url = attestation_sociale_url if jwt_roles.include? 'attestations_sociales'
    @attestation_fiscale_url = attestation_fiscale_url if jwt_roles.include? 'attestations_fiscales'
  end

  def entreprise
    response = @siade_client.entreprises(siret: @siret)

    response['entreprise']
  end

  def attestation_sociale_url
    response = @siade_client.attestations_sociales(siren: siren)

    response['url']
  end

  def attestation_fiscale_url
    response = @siade_client.attestations_fiscales(siren: siren)

    response['url']
  end

  def entreprise_raison_sociale
    entreprise['raison_sociale']
  end

  def entreprise_naf
    entreprise['naf_entreprise']
  end

  def entreprise_libelle_naf
    entreprise['libelle_naf_entreprise']
  end

  def entreprise_forme_juridique
    entreprise['forme_juridique']
  end

  def entreprise_categorie
    entreprise['categorie_entreprise']
  end

  def siren
    @siret.first(9)
  end
end
