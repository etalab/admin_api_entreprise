# frozen_string_literal: true

RSpec.shared_examples 'a blog post model' do
  describe '.all' do
    it 'returns an array' do
      expect(described_class.all).to be_an(Array)
    end
  end

  describe '.find' do
    it 'returns a blog post' do
      expect(described_class.find('hello-world').id).to eq('hello-world')
    end

    it 'raises ActiveRecord::RecordNotFound' do
      expect { described_class.find('not_found') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
