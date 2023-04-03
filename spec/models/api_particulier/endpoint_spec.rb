require 'rails_helper'

RSpec.describe APIParticulier::Endpoint do
  describe '.find' do
    subject { described_class.find(uid) }

    let(:uid) { 'cnaf/quotient_familial' }

    it { is_expected.to be_an_instance_of(described_class) }

    its(:uid) { is_expected.to eq(uid) }
    its(:path) { is_expected.to eq('/api/v2/composition-familiale') }

    its(:providers) { is_expected.to be_an_instance_of(Array) }

    its(:attributes) { is_expected.to be_an_instance_of(Hash) }
    its(:attributes) { is_expected.to have_key('quotientFamilial') }
  end
end
