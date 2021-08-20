require 'rails_helper'

RSpec.describe PrivateMetricsController, type: :controller do
  describe '#index' do
    describe 'fields' do
      let(:json) { json = JSON.parse(response.body) }

      before do
        allow_any_instance_of(ElasticClient).to receive(:establish_connection).and_return(true)

        allow_any_instance_of(ElasticClient).to receive(:raw_response).and_return(true)
        allow_any_instance_of(ElasticClient).to receive(:raw_response).and_return({
          "took"=>2130,
          "timed_out"=>false,
          "_shards"=>{"total"=>29, "successful"=>29, "skipped"=>0, "failed"=>0},
          "hits"=>{"total"=>{"value"=>10000, "relation"=>"gte"}, "max_score"=>nil, "hits"=>[]},
          "aggregations"=> {
            "unique-jti"=> {
              "doc_count_error_upper_bound"=>0,
              "sum_other_doc_count"=>0,
              "buckets"=> [
                {"key"=>"ab375719-986e-48b0-9bbb-d45fe9343cc3", "doc_count"=>8470146},
                {"key"=>"5af58470-f007-4102-8d48-016ce018de23", "doc_count"=>7800786},
                {"key"=>"fdc7196c-ba45-43b3-bf26-b0aaba44ee03", "doc_count"=>7710650}
              ]
            }
          }
        })
      end

      it 'structure is valid' do
        get :index

        expect(json.keys).to include("unused_jwt_list")
        expect(json["unused_jwt_list"]).to be_an(Array)
      end

      describe 'unused_jwt' do
        let!(:used_jwt_1)   { create(:jwt_api_entreprise, id: 'ab375719-986e-48b0-9bbb-d45fe9343cc3') }
        let!(:used_jwt_2)   { create(:jwt_api_entreprise, id: '5af58470-f007-4102-8d48-016ce018de23') }
        let!(:used_jwt_3)   { create(:jwt_api_entreprise, id: 'fdc7196c-ba45-43b3-bf26-b0aaba44ee03') }
        let!(:unused_jwt_1) { create(:jwt_api_entreprise, id: 'not-used') }

        it 'selects unused jwt' do
          get :index

          expect(json["unused_jwt_list"]).to include(unused_jwt_1.serializable_hash.as_json)
          expect(json["unused_jwt_list"].size).to eq(1)
        end

        it 'filters out used jwt' do
          get :index

          expect(json["unused_jwt_list"]).not_to include(used_jwt_1.serializable_hash.as_json)
          expect(json["unused_jwt_list"]).not_to include(used_jwt_2.serializable_hash.as_json)
          expect(json["unused_jwt_list"]).not_to include(used_jwt_3.serializable_hash.as_json)
        end
      end
    end
  end
end
