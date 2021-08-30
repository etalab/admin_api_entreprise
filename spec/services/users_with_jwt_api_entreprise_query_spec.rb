require 'rails_helper'

RSpec.describe UsersWithJwtApiEntrepriseQuery, type: :service do
  let!(:user_with_jwt)     { create(:user, :with_jwt) }
  let!(:user_without_jwt)  { create(:user) }

  it '#call returns users with jwt' do
    results = subject.perform

    expect(results).to      include(user_with_jwt)
    expect(results).not_to  include(user_without_jwt)

    expect(results.size).to eq(1)
  end
end
