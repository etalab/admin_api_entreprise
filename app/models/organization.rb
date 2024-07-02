class Organization
  attr_reader :siret

  def initialize(siret)
    @siret = siret
  end

  def denomination
    unite_legale_insee_payload['denominationUniteLegale']
  end

  def code_commune_etablissement
    adresse_etablissement_insee_payload['codeCommuneEtablissement']
  end

  def code_postal_etablissement
    adresse_etablissement_insee_payload['codePostalEtablissement']
  end

  private

  def adresse_etablissement_insee_payload
    etablissement_insee_payload['adresseEtablissement']
  end

  def etablissement_insee_payload
    insee_payload['etablissement']
  end

  def unite_legale_insee_payload
    etablissement_insee_payload['uniteLegale']
  end

  def insee_payload
    @insee_payload ||= INSEESireneAPIClient.new.etablissement(siret:)
  end
end
