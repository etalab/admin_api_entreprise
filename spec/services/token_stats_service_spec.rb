require 'rails_helper'

RSpec.describe TokenStatsService, type: :service do
  let(:token) { create(:jwt_api_entreprise) }
  let(:url) { "https://dashboard.entreprise.api.gouv.fr/api/watchdoge/stats/jwt_usage/#{token.id}" }
  let(:stubbed_request) do
    stub_request(:get, url).to_return({
      status: 200,
      body: '{"apis_usage":{"last_10_minutes":{"total":0,"by_endpoint":[]},"last_30_hours":{"total":0,"by_endpoint":[]},"last_8_days":{"total":13,"by_endpoint":[{"name":"Api/v2/etablissements restored","total":8,"percent_success":100,"percent_not_found":0,"percent_other_client_errors":0,"percent_server_errors":0},{"name":"Api/v2/entreprises restored","total":5,"percent_success":100,"percent_not_found":0,"percent_other_client_errors":0,"percent_server_errors":0}]}},"last_calls":[{"uname":"apie_3_entreprises","name":"Entreprise (INSEE v3)","url":"/v2/entreprises/382468874","params":[{"siren":"382468874"},{"context":"Tiers"},{"recipient":"20005375900011"},{"parameters_vrac":"{siren=382468874, context=Tiers, recipient=20005375900011, object=saisie institut, token=[FILTERED]}"},{"object":"saisie institut"}],"code":200,"timestamp":"2021-10-21T09:02:17.535Z"},{"uname":"apie_3_etablissements","name":"Etablissements (INSEE v3)","url":"/v2/etablissements/38246887400013","params":[{"context":"Tiers"},{"recipient":"20005375900011"},{"parameters_vrac":"{context=Tiers, recipient=20005375900011, siret=38246887400013, object=saisie institut, token=[FILTERED]}"},{"siret":"38246887400013"},{"object":"saisie institut"}],"code":200,"timestamp":"2021-10-21T09:02:16.635Z"}]}' })
  end

  before { stubbed_request }

  context 'when Watchdoge works' do
    describe '#stats_for_period' do
      subject { described_class.new(token.id) }

      it 'returns data for the last 10 minutes' do
        stats = subject.stats_for_period(:last_10_minutes)

        expect(stats).to include(
          total: 0,
          by_endpoint: []
        )
      end

      it 'returns data for the last 30 hours' do
        stats = subject.stats_for_period(:last_30_hours)

        expect(stats).to include(
          total: 0,
          by_endpoint: []
        )
      end

      it 'returns data for the last 8 days' do
        stats = subject.stats_for_period(:last_8_days)

        expect(stats).to include(
          total: 13,
          by_endpoint: a_collection_including(
            a_hash_including(
              name: 'Api/v2/etablissements restored',
              total: 8,
              percent_success: 100.0,
              percent_not_found: 0.0,
              percent_other_client_errors: 0.0,
              percent_server_errors: 0.0,
            )
          )
        )
      end
    end
  end

    context 'when Watchdoge does not work' do
      let(:stubbed_request) { stub_request(:get, url).to_timeout }
      subject { described_class.new(token.id).last_requests_details }

      it { is_expected.to be_nil }
    end
end
