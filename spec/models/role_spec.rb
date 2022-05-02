# frozen_string_literal: true

RSpec.describe Role do
  it 'has valid factories' do
    expect(build(:role)).to be_valid
  end
end
