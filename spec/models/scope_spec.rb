# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scope do
  it 'has valid factories' do
    expect(build(:scope)).to be_valid
  end

  describe '#valid' do
    it 'must have a valid API' do
      expect(build(:scope, api: 'wrong API')).not_to be_valid
    end
  end
end
