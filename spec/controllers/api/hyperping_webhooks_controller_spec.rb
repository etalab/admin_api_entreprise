require 'rails_helper'

RSpec.describe API::HyperpingWebhooksController do
  describe 'POST #create' do
    let(:valid_down_event_entreprise) do
      {
        event: 'down',
        check: {
          id: 'abc123',
          name: 'API Entreprise Ping',
          url: 'https://entreprise.api.gouv.fr/v3/ping',
          location: 'paris'
        }
      }
    end

    let(:up_event) do
      {
        event: 'up',
        check: {
          id: 'abc123',
          name: 'API Entreprise Ping',
          url: 'https://entreprise.api.gouv.fr/v3/ping',
          location: 'paris'
        }
      }
    end

    let(:unmonitored_url_event) do
      {
        event: 'down',
        check: {
          id: 'ghi789',
          name: 'API Entreprise Ping',
          url: 'https://other-api.example.com/ping',
          location: 'paris'
        }
      }
    end

    let!(:stubbed_request) do
      stub_request(:post, Rails.application.credentials.mattermost_webhook_url)
        .with(body: { text: '@all Alert! API Entreprise Ping is down' }.to_json)
        .to_return(status: 200)
    end

    context 'when receiving a down event for monitored URLs' do
      it 'notifies Mattermost' do
        post :create, params: valid_down_event_entreprise

        expect(response).to have_http_status(:ok)
        expect(stubbed_request).to have_been_requested
      end
    end

    context 'when receiving non-actionable events' do
      it 'does not notify Mattermost for up events' do
        post :create, params: up_event

        expect(response).to have_http_status(:ok)
        expect(stubbed_request).not_to have_been_requested
      end

      it 'does not notify Mattermost for unmonitored URLs' do
        post :create, params: unmonitored_url_event

        expect(response).to have_http_status(:ok)
        expect(stubbed_request).not_to have_been_requested
      end
    end
  end
end
