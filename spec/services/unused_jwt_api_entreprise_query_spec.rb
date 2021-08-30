require 'rails_helper'

RSpec.describe UnusedJwtApiEntrepriseQuery, type: :service do
  let!(:used_jwt)   { create_list(:jwt_api_entreprise, 3) }
  let!(:unused_jwt) { create(:jwt_api_entreprise) }

  before do
    allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return(
      used_jwt.pluck(:id)
    )
  end

  subject(:results) { described_class.new.perform }

  it 'returns unused_jwts only' do
    expect(results).not_to include(*used_jwt)
    expect(results).to include(unused_jwt)

    expect(results.size). to eq(1)
  end
end
