# frozen_string_literal: true

RSpec.describe Scope do
  it 'has valid factories' do
    expect(build(:scope)).to be_valid
  end
end
