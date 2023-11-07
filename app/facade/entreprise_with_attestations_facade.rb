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
    "#{entreprise.activite_principale[:code]} - #{entreprise.activite_principale[:libelle]}"
  end

  delegate :raison_sociale, to: :entreprise, prefix: true
  delegate :forme_juridique_libelle, to: :entreprise, prefix: true
  delegate :categorie_entreprise, to: :entreprise

  def with_attestation_fiscale?
    attestation_scope_service.include_attestation_fiscale?(@token)
  end

  def with_attestation_sociale?
    attestation_scope_service.include_attestation_sociale?(@token)
  end

  private

  def entreprise_result
    entreprise_interesting_keys = entreprise_payload.slice(
      :personne_morale_attributs, :activite_principale, :forme_juridique, :categorie_entreprise
    )

    Entreprise.new(entreprise_interesting_keys)
  end

  def entreprise_payload
    response = siade_client.entreprises(siren:)
    response.deep_transform_keys(&:to_sym)
  end

  def attestation_sociale_result
    siade_client.attestations_sociales(siren:)['document_url']
  end

  def attestation_fiscale_result
    siade_client.attestations_fiscales(siren:)['document_url']
  end

  def siade_client
    @siade_client ||= Siade.new(token: @token)
  end

  def attestations_scope_service
    @attestations_scope_service ||= AttestationsScopeService.new
  end
end
