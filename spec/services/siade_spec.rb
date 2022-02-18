require 'rails_helper'

RSpec.describe Siade, type: :service do
  let(:token) { apientreprise_test_token }

  describe '#entreprise',
    vcr: { cassette_name: 'services/siade/entreprise' }, type: :request do
    subject { described_class.new(token: token).entreprises(siret: siret_valid) }

    its(:net_http_res) { is_expected.to be_a(Net::HTTPOK) }
    its(:body) { is_expected.to include('JK ASSOCIATES CONSULTING') }
  end

  describe '#attestations_sociales',
    vcr: { cassette_name: 'services/siade/attestations_sociales' }, type: :request do
    subject { described_class.new(token: token).attestations_sociales(siren: siren_valid) }

    its(:net_http_res) { is_expected.to be_a(Net::HTTPOK) }
    its(:body) { is_expected.to include('attestation_vigilance_acoss.pdf') }
  end

  describe '#attestations_fiscales',
    vcr: { cassette_name: 'services/siade/attestations_fiscales' }, type: :request do
    subject { described_class.new(token: token).attestations_fiscales(siren: siren_valid) }

    its(:net_http_res) { is_expected.to be_a(Net::HTTPOK) }
    its(:body) { is_expected.to include('attestation_fiscale_dgfip.pdf') }
  end
end
