RSpec.describe APIParticulier::CasUsage do
  describe '#link_api_gouv' do
    it 'exists' do
      expect(described_class.all.first.link_api_gouv).to be_present
    end
  end
end
