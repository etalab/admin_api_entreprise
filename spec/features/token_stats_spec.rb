require 'rails_helper'

RSpec.describe 'stats page for a token', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  let(:token) { user.jwt_api_entreprise.take }

  subject { visit token_stats_path(token) }

  before do
    login_as(user)
    stubbed_request
  end

  context 'when Watchdoge works' do
    let(:url) { "https://dashboard.entreprise.api.gouv.fr/api/watchdoge/stats/jwt_usage/#{token.id}" }
    let(:body) { File.read(Rails.root.join('spec/fixtures/watchdoge_token_stats.json')) }

    let(:stubbed_request) do
      stub_request(:get, url).to_return({
        status: 200,
        body: body,
      })
    end

    it 'has a link back to the list of tokens' do
      subject

      expect(page).to have_link(href: user_tokens_path)
    end

    it 'displays the token use case' do
      subject

      expect(page).to have_content(token.displayed_subject)
    end

    it 'displays the token internal ID' do
      subject

      expect(page).to have_content(token.id)
    end

    describe 'calls rate' do
      it 'displays the rate of requests made with the token' do
        subject

        expect(page).to have_css('#calls_rate')
      end
    end

    describe 'the ratio of success and errors per providers', js: true do
      shared_examples :show_the_last_10_minutes_stats do
        it 'displays the corresponding period (no stats for 10mn in fixtures file)' do
          subject

          expect(page).to have_table('calls_ratio_last_10_minutes', with_rows: [])
        end

        it 'does not display stats from other periods' do
          subject

          expect(page).not_to have_table('calls_ratio_last_8_hours')
        end
      end

      context 'when visiting the page the first time' do
        subject { visit token_stats_path(token) }

        it_behaves_like :show_the_last_10_minutes_stats
      end

      context 'when clicking on a tab' do
        subject do
          visit token_stats_path(token)
          click_on("tabpanel-#{period}")
        end

        context 'for the last 10 minutes period' do
          let(:period) { 'last_10_minutes' }

          it_behaves_like :show_the_last_10_minutes_stats
        end

        context 'for the last 30 hours period' do
          let(:period) { 'last_30_hours' }

          it 'displays the corresponding period (no stats for 30h in fixtures file)' do
            subject

            expect(page).to have_table("calls_ratio_#{period}", with_rows: [])
          end

          it 'does not display stats from other periods' do
            subject

            expect(page).not_to have_table('calls_ratio_last_10_minutes')
          end
        end

        context 'for the last 8 days period' do
          let(:period) { 'last_8_days' }
          let(:expected_stats) do
            stats = JSON.parse(body, symbolize_names: true)
            stats[:apis_usage][period.to_sym][:by_endpoint].first
          end

          it 'displays the corresponding period' do
            subject

            expect(page).to have_table("calls_ratio_#{period}", with_rows: [])
          end

          it 'does not display stats from other periods' do
            subject

            expect(page).not_to have_table('calls_ratio_last_10_minutes')
          end

          it 'displays data in the right format' do
            subject

            expect(page).to have_table("calls_ratio_#{period}", with_rows: [
              [
                expected_stats[:name],
                expected_stats[:total],
                expected_stats[:percent_success],
                expected_stats[:percent_not_found],
                expected_stats[:percent_other_client_errors],
                expected_stats[:percent_server_errors],
              ]
            ])
          end
        end
      end
    end

    describe 'last calls details' do
      let(:one_of_the_last_calls) do
        stats = JSON.parse(body, symbolize_names: true)
        stats[:last_calls].first
      end

      it 'displays the details of the last few calls' do
        subject

        expect(page).to have_table('requests_details', with_rows: [
          [
            one_of_the_last_calls[:url],
            one_of_the_last_calls[:params].to_s,
            one_of_the_last_calls[:code],
          ]
        ])
      end
    end
  end

  context 'when Watchdoge does not work' do
    let(:url) { "https://dashboard.entreprise.api.gouv.fr/api/watchdoge/stats/jwt_usage/#{token.id}" }

    let(:stubbed_request) do
      stub_request(:get, url).to_timeout
    end

    it_behaves_like :display_alert, :error

    it 'redirects to the token index page' do
      subject

      expect(page).to have_current_path(user_tokens_path)
    end
  end
end
