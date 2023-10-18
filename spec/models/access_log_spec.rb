require 'rails_helper'

RSpec.describe AccessLog do
  let(:access_log) { create(:access_log) }

  it 'has valid factories' do
    expect(build(:access_log)).to be_valid
  end
end
