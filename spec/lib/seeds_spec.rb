require 'rails_helper'

RSpec.describe Seeds do
  describe '#perform' do
    it 'does not raise error' do
      expect {
        subject
      }.not_to raise_error
    end
  end
end
