RSpec.describe Endpoint, type: :model do
  describe '.all' do
    subject { described_class.all }

    it { is_expected.to be_an_instance_of(Array) }

    describe 'an element' do
      subject { described_class.all.first }

      it { is_expected.to be_an_instance_of(Endpoint) }
    end
  end

  describe '.find' do
    subject { described_class.find(uid) }

    context 'with valid uid' do
      let(:uid) { 'insee/entreprise' }

      it { is_expected.to be_an_instance_of(Endpoint) }

      its(:uid) { is_expected.to eq(uid) }
      its(:path) { is_expected.to eq('/v3/insee/entreprises/{siren}') }

      its(:providers) { is_expected.to be_an_instance_of(Array) }
      its(:perimeter) { is_expected.to be_present }
      its(:opening) { is_expected.to be_present }

      its(:attributes) { is_expected.to be_an_instance_of(Hash) }
      its(:attributes) { is_expected.to have_key('date_creation') }

      its(:links) { is_expected.to be_an_instance_of(Hash) }
      its(:links) { is_expected.to have_key('siege_social') }

      its(:meta) { is_expected.to be_an_instance_of(Hash) }
      its(:meta) { is_expected.to have_key('date_derniere_mise_a_jour') }
    end

    context 'with invalid uid' do
      let(:uid) { 'whatever' }

      it 'raises a record found error' do
        expect {
          subject
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
