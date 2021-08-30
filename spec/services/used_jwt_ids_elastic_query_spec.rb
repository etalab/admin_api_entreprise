require 'rails_helper'

RSpec.describe UsedJwtIdsElasticQuery, type: :service do
  let(:used_jwt_id_1){ "ab375719-986e-48b0-9bbb-d45fe9343cc3" }
  let(:used_jwt_id_2){ "5af58470-f007-4102-8d48-016ce018de23" }
  let(:used_jwt_id_3){ "fdc7196c-ba45-43b3-bf26-b0aaba44ee03" }

  before do
    allow($elastic).to receive(:search).and_return({
      "took"=>2130,
      "timed_out"=>false,
      "_shards"=>{"total"=>29, "successful"=>29, "skipped"=>0, "failed"=>0},
      "hits"=>{"total"=>{"value"=>10000, "relation"=>"gte"}, "max_score"=>nil, "hits"=>[]},
      "aggregations"=> {
        "unique-jti"=> {
          "doc_count_error_upper_bound"=>0,
          "sum_other_doc_count"=>0,
          "buckets"=> [
            {"key"=> used_jwt_id_1, "doc_count"=>8470146},
            {"key"=> used_jwt_id_2, "doc_count"=>7800786},
            {"key"=> used_jwt_id_3, "doc_count"=>7710650}
          ]
        }
      }
    })
  end

  subject { described_class.new }

  it '#perform extracts used jwt ids and returns them' do
    results = subject.perform

    expect(results).to be_an(Array)
    expect(results.size).to eq(3)
    expect(results).to include(*[used_jwt_id_2, used_jwt_id_1, used_jwt_id_3])
  end
end
