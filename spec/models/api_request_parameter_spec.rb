require 'rails_helper'

RSpec.describe APIRequestParameter do
  describe '#label' do
    it 'returns the input_name (technical name)' do
      param = described_class.new(name: 'nomNaissance')

      expect(param.label).to eq('nomNaissance')
    end

    it 'strips array suffix' do
      param = described_class.new(name: 'prenoms[]')

      expect(param.label).to eq('prenoms')
    end
  end

  describe '#input_name' do
    it 'removes array suffix' do
      param = described_class.new(name: 'prenoms[]')

      expect(param.input_name).to eq('prenoms')
    end

    it 'returns name unchanged when no suffix' do
      param = described_class.new(name: 'siren')

      expect(param.input_name).to eq('siren')
    end
  end

  describe '#array?' do
    it 'returns true when name ends with []' do
      param = described_class.new(name: 'prenoms[]')

      expect(param.array?).to be(true)
    end

    it 'returns false when name does not end with []' do
      param = described_class.new(name: 'siren')

      expect(param.array?).to be(false)
    end
  end

  describe 'attributes' do
    it 'exposes name, required and location' do
      param = described_class.new(
        name: 'siren',
        required: true,
        location: 'path'
      )

      expect(param.name).to eq('siren')
      expect(param.required).to be(true)
      expect(param.location).to eq('path')
    end

    it 'defaults required to false' do
      param = described_class.new(name: 'optional_param')

      expect(param.required).to be(false)
    end
  end
end
