RSpec.describe DocumentationSearchableChunk do
  describe '.all' do
    subject { described_class.all }

    it { is_expected.to be_a(Array) }
  end
end
