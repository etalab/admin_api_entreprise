RSpec.describe AlgoliaReindexer do
  let(:instance) { described_class.new }

  describe '#perform' do
    subject { instance.perform }

    # rubocop:disable RSpec/VerifiedDoubles
    let(:fake_models) { [fake_model, another_fake_model] }
    let(:fake_model) { double(ApplicationAlgoliaSearchableActiveModel) }
    let(:another_fake_model) { double(ApplicationAlgoliaSearchableActiveModel, reindex: true) }
    # rubocop:enable RSpec/VerifiedDoubles

    before do
      allow(instance).to receive(:indexable_models).and_return(fake_models)
    end

    context 'when algolia works' do
      before do
        allow(fake_model).to receive(:reindex)
      end

      it 'reindexes all models' do
        expect(fake_models).to all(receive(:reindex))

        subject
      end

      it 'does not raise error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when algolia raises an error' do
      before do
        allow(fake_model).to receive(:reindex).and_raise(Algolia::AlgoliaError)
      end

      it 'does not reindex model' do
        expect(another_fake_model).not_to receive(:reindex)

        subject
      end

      it 'does not raise error' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when there is another error' do
      before do
        allow(fake_model).to receive(:reindex).and_raise(StandardError)
      end

      it 'does not reindex model' do
        expect(another_fake_model).not_to receive(:reindex)

        subject
      rescue StandardError
      end

      it 'raises error' do
        expect { subject }.to raise_error(StandardError)
      end
    end
  end
end
