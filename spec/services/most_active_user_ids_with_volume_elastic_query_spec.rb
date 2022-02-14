require 'rails_helper'

RSpec.describe MostActiveUserIdsWithVolumeElasticQuery, type: :service do
  subject(:results) { described_class.new.perform }

  before do
    allow($elastic).to receive(:search).and_return({
      'took' => 244,
      'timed_out' => false,
      '_shards' => { 'total' => 19, 'successful' => 19, 'skipped' => 0, 'failed' => 0 },
      'hits' => { 'total' => { 'value' => 10_000, 'relation' => 'gte' }, 'max_score' => nil, 'hits' => [] },
      'aggregations' => {
        'most_active_users' => {
          'doc_count_error_upper_bound' => 43_938,
          'sum_other_doc_count' => 2_620_454,
          'buckets' => [
            { 'key' => 'b2ead62b-a6d1-477f-8b62-ae9b78e4252c', 'doc_count' => 2_444_633 },
            { 'key' => 'ee9709ff-d8af-4c76-9086-031879c4a264', 'doc_count' => 1_404_274 },
            { 'key' => '522efb4d-5fc0-4b08-bf81-27e7d8e86bf7', 'doc_count' => 640_343 },
            { 'key' => 'f5d5cb02-185a-426f-b3f4-99a25ce6cdf4', 'doc_count' => 506_852 },
            { 'key' => 'bfffc4c7-0626-40a4-b8dc-558d51eddc4c', 'doc_count' => 505_139 },
            { 'key' => '5a7cd98d-94b5-4c10-b6a2-f57ce3701070', 'doc_count' => 439_904 },
            { 'key' => 'e7bced5c-b217-457a-ae13-0f384256139d', 'doc_count' => 419_688 },
            { 'key' => 'd92439a9-7e47-4111-a6e5-10e96b5a2ccc', 'doc_count' => 413_501 },
            { 'key' => '7b34e6a1-bdc5-42eb-89ed-a2ca12ba0741', 'doc_count' => 208_321 },
            { 'key' => '2a905efa-4cd3-406d-b1f5-c3b6f8dbe1a0', 'doc_count' => 195_309 }
          ]
        }
      }
    })
  end

  it 'returns most calling user ids' do
    expect(results).to eq([
      ['b2ead62b-a6d1-477f-8b62-ae9b78e4252c', 2_444_633],
      ['ee9709ff-d8af-4c76-9086-031879c4a264', 1_404_274],
      ['522efb4d-5fc0-4b08-bf81-27e7d8e86bf7', 640_343],
      ['f5d5cb02-185a-426f-b3f4-99a25ce6cdf4', 506_852],
      ['bfffc4c7-0626-40a4-b8dc-558d51eddc4c', 505_139],
      ['5a7cd98d-94b5-4c10-b6a2-f57ce3701070', 439_904],
      ['e7bced5c-b217-457a-ae13-0f384256139d', 419_688],
      ['d92439a9-7e47-4111-a6e5-10e96b5a2ccc', 413_501],
      ['7b34e6a1-bdc5-42eb-89ed-a2ca12ba0741', 208_321],
      ['2a905efa-4cd3-406d-b1f5-c3b6f8dbe1a0', 195_309]
    ])
  end
end
