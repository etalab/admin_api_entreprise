require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe '.all' do
    subject { described_class.all }

    it 'returns a list of providers' do
      expect(subject).to all be_a(described_class)
    end
  end
end
