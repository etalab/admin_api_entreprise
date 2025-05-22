require 'rails_helper'

RSpec.describe Organization do
  it 'has a valid factory' do
    expect(build(:organization)).to be_valid
  end
end
