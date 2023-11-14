RSpec.describe Entreprise do
  it 'has a valid factory' do
    expect(build(:entreprise)).to be_valid
  end
end
