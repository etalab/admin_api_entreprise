require 'rails_helper'

RSpec.describe Organization do
  it 'has a valid factory' do
    expect(build(:organization)).to be_valid
    expect(build(:organization, :with_insee_payload, siret: '13002526500013')).to be_valid
  end
end
