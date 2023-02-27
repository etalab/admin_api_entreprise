RSpec.describe MetabaseEmbedService, type: :service do
  describe '#url' do
    subject { described_class.new(question_id, params).url }

    let(:question_id) { 1 }
    let(:params) { { 'interval' => '10 minutes' } }

    it 'does not raise an error' do
      expect { subject }.not_to raise_error
    end
  end
end
