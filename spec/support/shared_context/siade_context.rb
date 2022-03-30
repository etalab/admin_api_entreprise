RSpec.shared_context 'with siade payloads' do
  let(:payload_entreprise) do
    {
      'entreprise' => {
        'raison_sociale' => 'dummy name',
        'forme_juridique' => 'dummy forme juridique',
        'categorie_entreprise' => 'dummy cat. entreprise',
        'naf_entreprise' => 'dummy naf',
        'libelle_naf_entreprise' => 'dummy libelle naf'
      }
    }
  end

  let(:payload_attestation_sociale) do
    {
      'url' => 'http://entreprise.api.gouv.fr/uploads/attestation_sociale.pdf'
    }
  end

  let(:payload_attestation_fiscale) do
    {
      'url' => 'http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf'
    }
  end
end
