RSpec.shared_context 'with siade payloads' do
  let(:payload_error) { { errors: [{ detail: 'Siade error msg' }] }.to_json }

  let(:payload_entreprise) do
    File.read('spec/fixtures/insee_unite_legale_example.json')
  end

  let(:payload_attestation_sociale) do
    {
      data: {
        document_url: 'https://storage.entreprise.api.gouv.fr/url-de-telechargement-attestation-vigilance.pdf',
        document_url_expires_in: 86_400,
        date_debut_validite: '2023-01-31',
        date_fin_validite: '2023-07-31',
        code_securite: 'YAB458G1B2T8IZW',
        entity_status: {
          code: 'ok',
          libelle: "Attestation délivrée par l'Urssaf",
          description: "La délivrance de l'attestation de vigilance a été validée par l'Urssaf. L'attestation est délivrée lorsque l'entité est à jour de ses cotisations et contributions, ou bien dans le cas de situations spécifiques détaillées dans la documentation métier."
        }
      },
      links: {},
      meta: {}
    }.to_json
  end

  let(:payload_attestation_fiscale) do
    {
      data: {
        document_url: 'https://entreprise.api.gouv.fr/files/attestation-fiscale-dgfip-exemple.pdf',
        expires_in: 1_234_567
      },
      links: {},
      meta: {}
    }.to_json
  end
end
