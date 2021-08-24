require 'rails_helper'

RSpec.describe UsersWithoutJwtApiEntrepriseQuery, type: :service do
  let!(:user_with_jwt)     { create(:user, :with_jwt) }
  let!(:user_without_jwt)  { create(:user) }

  it '#call returns users without any jwt' do
    results = subject.perform

    expect(results).not_to include(user_with_jwt)
    expect(results).to include(user_without_jwt)

    expect(results.size).to eq(1)
  end
end
