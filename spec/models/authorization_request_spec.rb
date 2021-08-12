require 'rails_helper'

RSpec.describe AuthorizationRequest, type: :model do
  it 'has valid factory' do
    expect(build(:authorization_request)).to be_valid
  end
end
