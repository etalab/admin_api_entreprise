class EntrepriseWithAttestationsFacade
  attr_reader :siren,
    :entreprise,
    :attestation_sociale_url,
    :attestation_fiscale_url,
    :error

  def initialize(token:, siren:)
    @token = token
    @siren = siren.try(:strip)
  end

  def success?
    @error.nil?
  end

  def perform
    retrieve_company
    retrieve_attestation_sociale
    retrieve_attestation_fiscale
  rescue SiadeClientError => e
    @error = e
  end

  def retrieve_company
    @entreprise = build_entreprise
  end

  # rubocop:disable Lint/SuppressedException
  def retrieve_attestation_sociale
    @attestation_sociale_url = attestation_sociale_result
  rescue SiadeClientError
  end
  # rubocop:enable Lint/SuppressedException

  # rubocop:disable Lint/SuppressedException
  def retrieve_attestation_fiscale
    @attestation_fiscale_url = attestation_fiscale_result
  rescue SiadeClientError
  end
  # rubocop:enable Lint/SuppressedException

  def build_entreprise
    Entreprise.new(
      entreprise_payload.slice(
        :personne_morale_attributs,
        :activite_principale,
        :forme_juridique,
        :categorie_entreprise
      )
    )
  end

  def entreprise_payload
    siade_client.entreprises(siren:).deep_transform_keys(&:to_sym)
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
end
