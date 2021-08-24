require 'rails_helper'

RSpec.describe UnusedJwtApiEntrepriseQuery, type: :service do
  let(:used_jwt_id_1){ "ab375719-986e-48b0-9bbb-d45fe9343cc3" }
  let(:used_jwt_id_2){ "5af58470-f007-4102-8d48-016ce018de23" }
  let(:used_jwt_id_3){ "fdc7196c-ba45-43b3-bf26-b0aaba44ee03" }

  let!(:used_jwt_1)   { create(:jwt_api_entreprise, id: used_jwt_id_1) }
  let!(:used_jwt_2)   { create(:jwt_api_entreprise, id: used_jwt_id_2) }
  let!(:used_jwt_3)   { create(:jwt_api_entreprise, id: used_jwt_id_3) }
  let!(:unused_jwt_1) { create(:jwt_api_entreprise, id: 'not-used') }

  before do
    allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return(
      [used_jwt_id_1, used_jwt_id_2, used_jwt_id_3]
    )
  end

  it '#perform returns unused_jwts only' do
    results = subject.perform

    expect(results).not_to include(*[used_jwt_1, used_jwt_2, used_jwt_3])
    expect(results).to include(unused_jwt_1)

    expect(results.size). to eq(1)
  end
end
