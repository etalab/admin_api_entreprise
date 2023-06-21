RSpec.describe APIEntreprise::EndpointsStore, type: :store do
  describe '.all' do
    subject { described_class.all }

    it { is_expected.to be_an_instance_of(Array) }

    it 'loads endpoints from backend files' do
      expect(subject.count).to be >= 1
    end

    it 'is ordered by position' do
      positions = subject.pluck(:position)

      expect(positions).to eq(positions.sort)
    end

    describe 'an element' do
      subject { described_class.all.first }

      it { is_expected.to have_key('uid') }
      it { is_expected.to have_key('path') }
    end
  end

  describe '.find' do
    subject { described_class.find(uid) }

    context 'with valid uid' do
      let(:uid) { api_entreprise_example_uid }

      it { is_expected.to be_present }

      it { is_expected.to have_key('uid') }
      it { is_expected.to have_key('path') }
    end

    context 'with invalid uid' do
      let(:uid) { 'whatever' }

      it { is_expected.to be_nil }
    end
  end
end
