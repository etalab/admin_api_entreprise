require 'rails_helper'

RSpec.describe APIParticulier::Endpoint do
  let(:uid) { 'cnav/quotient_familial_v2' }

  describe '.find' do
    subject { described_class.find(uid) }

    it { is_expected.to be_an_instance_of(described_class) }

    its(:uid) { is_expected.to eq(uid) }
    its(:path) { is_expected.to eq('/v3/dss/quotient_familial/identite') }

    its(:providers) { is_expected.to be_an_instance_of(Array) }

    its(:attributes) { is_expected.to be_an_instance_of(Hash) }
    its(:attributes) { is_expected.to have_key('allocataires') }
    its(:attributes) { is_expected.to have_key('adresse') }
  end

  describe '#test_cases_external_url' do
    subject { described_class.find(uid).test_cases_external_url }

    it { is_expected.to eq('https://github.com/etalab/siade_staging_data/tree/develop/payloads/api_particulier_v3_cnav_quotient_familial_with_civility') }
  end

  describe '#redoc_anchor' do
    subject { described_class.find(uid).redoc_anchor }

    it { is_expected.to eq('tag/Quotient-familial-CAF-and-MSA/paths/~1v3~1dss~1quotient_familial~1identite/get') }
  end
end
