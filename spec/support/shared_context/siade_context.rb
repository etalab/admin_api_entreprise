RSpec.shared_context 'with siade payloads' do
  let(:payload_entreprise) do
    {
      entreprise: {
        raison_sociale: 'dummy name',
        forme_juridique: 'dummy forme juridique',
        categorie_entreprise: 'dummy cat. entreprise',
        naf_entreprise: 'dummy naf',
        libelle_naf_entreprise: 'dummy libelle naf'
      }
    }.to_json
  end

  let(:payload_attestation_sociale) do
    {
      url: 'dummy url sociale'
    }.to_json
  end

  let(:payload_attestation_fiscale) do
    {
      url: 'dummy url fiscale'
    }.to_json
  end
end
