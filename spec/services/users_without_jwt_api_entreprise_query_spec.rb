require 'rails_helper'

RSpec.describe UsersWithoutJwtApiEntrepriseQuery, type: :service do
  let!(:user_with_jwt)     { create(:user, :with_jwt) }
  let!(:user_without_jwt)  { create(:user) }

  subject(:results) { described_class.new.perform }

  it 'returns users without any jwt' do
    expect(results).to eq([user_without_jwt])
  end
end
