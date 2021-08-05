require 'rails_helper'

RSpec.describe PrivateMetricsController, type: :controller do
  describe '#index' do
    describe 'fields' do
      it 'structure is valid' do
        get :index

        expect(response_json.keys).to include(:unused_jwt)
      end

      describe 'unused_jwt' do

        let!(:all_jwt) { create_list(:jwt_api_entreprise, 3) }
        let!(:used_jwt){ all_jwt.first }
        let!(:used_jti){ used_jwt.id }

        before do
          expect_any_instance_of(PrivateMetricsController).to receive(:used_jti).and_return([used_jti])

          get :index
        end

        it 'filters out used jwt' do
          unused_jwt = JSON.parse(response.body)["unused_jwt"]
          used_jwt_as_json_hash = JSON.parse(used_jwt.to_json)

          expect(unused_jwt).not_to include(used_jwt_as_json_hash)
          expect(unused_jwt.size).to eq(2)
        end

        it 'selects unused jwt' do
          unused_jwt = JSON.parse(response.body)["unused_jwt"]
          unused_jwt_in_json_body_1 = JSON.parse(all_jwt[1].to_json)
          unused_jwt_in_json_body_2 = JSON.parse(all_jwt[2].to_json)

          expect(unused_jwt).to include(unused_jwt_in_json_body_1)
          expect(unused_jwt).to include(unused_jwt_in_json_body_2)
        end
      end
    end
  end
end
