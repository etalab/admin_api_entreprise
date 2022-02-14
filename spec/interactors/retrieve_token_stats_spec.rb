require 'rails_helper'

RSpec.describe RetrieveTokenStats do
  subject { described_class.call(token_id: token.id) }

  context 'when the token does not exist' do
    let(:token) { build(:jwt_api_entreprise) }

    it { is_expected.to be_a_failure }
  end

  context 'when the token exists' do
    let(:token) { create(:jwt_api_entreprise) }

    context 'when backend for stats works' do
      let(:url) { "https://dashboard.entreprise.api.gouv.fr/api/watchdoge/stats/jwt_usage/#{token.id}" }
      let(:body) { File.read(Rails.root.join('spec/fixtures/watchdoge_token_stats.json')) }

      let(:stubbed_request) do
        stub_request(:get, url).to_return({
          status: 200,
          body: body
        })
      end

      before { stubbed_request }

      it { is_expected.to be_a_success }

      it 'returns the stats' do
        expect(subject.stats).to include(
          last_8_days: a_collection_including(a_hash_including(
            name: 'Api/v2/etablissements restored',
            total: 8,
            percent_success: 100.0,
            percent_not_found: 0.0,
            percent_other_client_errors: 0.0,
            percent_server_errors: 0.0
          )),
          last_30_hours: Array,
          last_10_minutes: Array,
          last_requests: a_collection_including(a_hash_including(
            uname: 'apie_3_entreprises',
            name: 'Entreprise (INSEE v3)',
            url: '/v2/entreprises/382468874',
            params: anything,
            code: 200,
            timestamp: '2021-10-21T09:02:17.535Z'
          ))
        )
      end

      its(:stats) { is_expected.to include(:last_8_days, :last_requests) }
    end

    context 'when backend for stats does not work' do
      let(:url) { "https://dashboard.entreprise.api.gouv.fr/api/watchdoge/stats/jwt_usage/#{token.id}" }

      let(:stubbed_request) do
        stub_request(:get, url).to_timeout
      end

      before { stubbed_request }

      it { is_expected.to be_a_failure }
    end
  end
end
