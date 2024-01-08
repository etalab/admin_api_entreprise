require 'rails_helper'

RSpec.describe APIParticulier::Endpoint do
  let(:uid) { 'cnaf/quotient_familial' }

  describe '.find' do
    subject { described_class.find(uid) }

    it { is_expected.to be_an_instance_of(described_class) }

    its(:uid) { is_expected.to eq(uid) }
    its(:path) { is_expected.to eq('/api/v2/composition-familiale') }

    its(:providers) { is_expected.to be_an_instance_of(Array) }

    its(:attributes) { is_expected.to be_an_instance_of(Hash) }
    its(:attributes) { is_expected.to have_key('quotientFamilial') }
  end

  describe '#test_cases_external_url' do
    subject { described_class.find(uid).test_cases_external_url }

    it { is_expected.to eq('https://github.com/etalab/siade_staging_data/tree/develop/payloads/api_particulier_v2_cnaf_quotient_familial') }
  end

  describe '#redoc_anchor' do
    subject { described_class.find(uid).redoc_anchor }

    it { is_expected.to eq('tag/Quotient-familial/paths/~1api~1v2~1composition-familiale/get') }
  end
end
