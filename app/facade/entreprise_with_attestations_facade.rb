class EntrepriseWithAttestationsFacade
  attr_reader :siren, :entreprise, :attestation_sociale_url, :attestation_fiscale_url

  def initialize(token:, siren:)
    @token = token
    @siren = siren

    @token_scopes = @token.scopes
  end

  def retrieve_company
    @entreprise = entreprise_result
  end

  def retrieve_attestation_sociale
    @attestation_sociale_url = attestation_sociale_result if @token_scopes.include? 'attestations_sociales'
  end

  def retrieve_attestation_fiscale
    @attestation_fiscale_url = attestation_fiscale_result if @token_scopes.include? 'attestations_fiscales'
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
    response = siade_client.entreprises(siren:)

    response['entreprise'].transform_keys(&:to_sym)
  end

  def attestation_sociale_result
    siade_client.attestations_sociales(siren:)['url']
  end

  def attestation_fiscale_result
    siade_client.attestations_fiscales(siren:)['url']
  end

  def siade_client
    @siade_client ||= Siade.new(token: @token)
  end
end
