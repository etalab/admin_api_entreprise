require 'rails_helper'

RSpec.describe ElasticClient, type: :service do
  context 'when API access is allowed' do
    subject(:client) { described_class.new }

    before { client.establish_connection }

    context 'with a search query', vcr: { cassette_name: 'basic_search_json_query_allowed' } do
      before { client.search basic_search_json_query }

      let(:basic_search_json_query) do
        {
          "size": 1,
          "query": {
            "match_all": {}
          }
        }
      end

      its(:success?) { is_expected.to be_truthy }
      its(:raw_response) { is_expected.to be_kind_of(Hash) }
      its(:errors) { is_expected.to be_empty }
    end

    context 'with a count query', vcr: { cassette_name: 'basic_count_json_query_allowed' } do
      before { client.count basic_count_json_query }

      let(:basic_count_json_query) do
        {
          "query": {
            "bool": {
              "must": [
                {
                  "range": {
                    "@timestamp": {
                      "gte": 'now-1M',
                      "lte": 'now/d'
                    }
                  }
                }
              ]
            }
          }
        }
      end

      its(:success?) { is_expected.to be_truthy }
      its(:raw_response) { is_expected.to be_kind_of(Hash) }
      its(:errors) { is_expected.to be_empty }
    end
  end

  # VCR cassette is not generated but it is mandatory a HTTP request is performed
  describe 'when API access is forbidden', vcr: { cassette_name: 'basic_json_query_denied_TO_DELETE' } do
    # better perf
    # rubocop:disable RSpec/InstanceVariable
    subject { @access_denied }

    # rubocop:enable RSpec/InstanceVariable

    before do
      remember_through_tests('access_denied') do
        client = described_class.new
        client.establish_connection
        client
      end
    end

    its(:success?) { is_expected.to be_falsey }
    its(:raw_response) { is_expected.to be_nil }
    its(:errors) { is_expected.not_to be_empty }
  end
end
