require 'rails_helper'

RSpec.describe Seeds do
  describe '#perform' do
    subject { described_class.new.perform }

    it 'does not raise error' do
      expect {
        subject
      }.not_to raise_error
    end
  end

  describe '#flushdb' do
    subject { described_class.new.flushdb }

    it 'does not raise error' do
      expect {
        subject
      }.not_to raise_error
    end

    context 'when in production' do
      before do
        allow(Rails).to receive(:env).and_return('production')
      end

      it 'raises error' do
        expect {
          subject
        }.to raise_error(StandardError)
      end
    end
  end
end
