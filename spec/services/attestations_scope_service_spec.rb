RSpec.describe AttestationsScopeService, type: :service do
  subject(:attestations_scope_service) { described_class.new }

  let!(:token) { create(:token) }
  let!(:token_with_attestation_sociale) { create(:token, scopes: ['attestations_sociales']) }
  let!(:token_with_attestation_fiscale) { create(:token, scopes: ['attestations_fiscales']) }
  let!(:token_with_attestation_sociale_and_fiscale) { create(:token, scopes: %w[attestations_sociales attestations_fiscales]) }

  it 'gets best token to retrieve attestations' do
    expect(subject.best_token_to_retrieve_attestations(
        [
          token,
          token_with_attestation_sociale,
          token_with_attestation_fiscale,
          token_with_attestation_sociale_and_fiscale
        ]
      )).to eq(token_with_attestation_sociale_and_fiscale)
  end

  it 'retrieves attestations scopes' do
    expect(subject.attestations_scopes(token)).to eq([])
    expect(subject.attestations_scopes(token_with_attestation_sociale)).to eq(['attestations_sociales'])
    expect(subject.attestations_scopes(token_with_attestation_fiscale)).to eq(['attestations_fiscales'])
    expect(subject.attestations_scopes(token_with_attestation_sociale_and_fiscale)).to eq(%w[attestations_sociales attestations_fiscales])
  end

  it 'returns true if token includes attestation sociale' do
    expect(subject.include_attestation_sociale?(token)).to be(false)
    expect(subject.include_attestation_sociale?(token_with_attestation_sociale)).to be(true)
    expect(subject.include_attestation_sociale?(token_with_attestation_fiscale)).to be(false)
    expect(subject.include_attestation_sociale?(token_with_attestation_sociale_and_fiscale)).to be(true)
  end

  it 'returns true if token includes attestation fiscale' do
    expect(subject.include_attestation_fiscale?(token)).to be(false)
    expect(subject.include_attestation_fiscale?(token_with_attestation_sociale)).to be(false)
    expect(subject.include_attestation_fiscale?(token_with_attestation_fiscale)).to be(true)
    expect(subject.include_attestation_fiscale?(token_with_attestation_sociale_and_fiscale)).to be(true)
  end
end
