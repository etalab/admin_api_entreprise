require 'rails_helper'

RSpec.describe MonthPlusOldNotInProductionJwtIdsElasticQuery, type: :service do
  let(:production_delayed_jwt_1){ "ab375719-986e-48b0-9bbb-d45fe9343cc3" }
  let(:production_delayed_jwt_2){ "5af58470-f007-4102-8d48-016ce018de23" }

  before do
    allow($elastic).to receive(:search).and_return({
      "took"=>1435,
      "timed_out"=>false,
      "_shards"=>{"total"=>19, "successful"=>19, "skipped"=>0, "failed"=>0},
      "hits"=>{"total"=>{"value"=>10000, "relation"=>"gte"}, "max_score"=>nil, "hits"=>[ ]},
      "aggregations"=>{
        "production-delayed-jti"=>{
          "doc_count_error_upper_bound"=>0,
          "sum_other_doc_count"=>0,
          "buckets"=>[
            {
              "key"=>production_delayed_jwt_1,
              "doc_count"=>810725,
              "unique_rna"=>{"value"=>0},
              "unique_siret"=>{"value"=>5},
              "unique_siren"=>{"value"=>5},
              "unique_ids_count"=>{ "value"=>10.0}
            },
            {
              "key"=>production_delayed_jwt_2,
              "doc_count"=>699084,
              "unique_rna"=>{"value"=>12},
              "unique_siret"=>{"value"=>6},
              "unique_siren"=>{"value"=>1},
              "unique_ids_count"=>{"value"=>19.0}
            }
    			]
    		}
    	}
    })
  end

  subject(:results) { described_class.new.perform }

  it '#perform extracts used jwt ids and returns them' do
    expect(results).to eq([production_delayed_jwt_1, production_delayed_jwt_2])
  end
end
