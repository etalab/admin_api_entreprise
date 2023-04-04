RSpec.describe DocumentationSearchableChunk do
  describe '.all' do
    subject { described_class.all }

    it { is_expected.to be_a(Array) }
    it { expect(subject).to all be_a(described_class) }
  end
end
