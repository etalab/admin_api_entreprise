require 'rails_helper'

RSpec.describe APIParticulier::EndpointV2 do
  let(:uid) { 'cnav/v2/quotient_familial_v2' }

  describe '.all' do
    it 'contains only v2 endpoints' do
      expect(described_class.all.map(&:uid)).to include('cnav/v2/quotient_familial_v2')
      expect(described_class.all.map(&:uid)).not_to include('cnav/quotient_familial')
    end
  end

  describe '.find' do
    subject { described_class.find(uid) }

    it { is_expected.to be_an_instance_of(described_class) }

    its(:uid) { is_expected.to eq(uid) }
    its(:path) { is_expected.to eq('/api/v2/composition-familiale-v2') }

    its(:providers) { is_expected.to be_an_instance_of(Array) }

    its(:attributes) { is_expected.to be_an_instance_of(Hash) }
    its(:attributes) { is_expected.to have_key('allocataires') }
    its(:attributes) { is_expected.to have_key('adresse') }

    its(:title) { is_expected.to eq('Quotient familial MSA & CAF') }
  end

  describe '#test_cases_external_url' do
    subject { described_class.find(uid).test_cases_external_url }

    it { is_expected.to eq('https://github.com/etalab/siade_staging_data/tree/develop/payloads/api_particulier_v2_cnav_quotient_familial_v2') }
  end

  describe '#redoc_anchor' do
    subject { described_class.find(uid).redoc_anchor }

    it { is_expected.to eq('tag/Quotient-familial/paths/~1api~1v2~1composition-familiale-v2/get') }
  end
end
