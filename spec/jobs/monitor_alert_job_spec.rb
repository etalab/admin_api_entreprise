RSpec.describe MonitorAlertJob do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    let(:mattermost_webhook_url) { Rails.application.credentials.mattermost_webhook_url }
    let(:stubbed_mattermost_request) do
      stub_request(:post, mattermost_webhook_url).with(
        headers: { 'Content-Type' => 'application/json' },
        body: hash_including(text: match(/Banque de France - Bilans/))
      ).to_return(status: 200, body: 'ok')
    end

    before do
      stubbed_mattermost_request
    end

    context 'when monitors are down' do
      before do
        stub_hyperping_request_monitor_down('entreprise')
        stub_hyperping_request_operational('particulier')
      end

      it 'sends alert to Mattermost with monitor name' do
        perform_job

        expect(stubbed_mattermost_request).to have_been_requested
      end

      it 'includes the down monitor name in the alert message' do
        perform_job

        expect(stubbed_mattermost_request.with do |req|
          body = JSON.parse(req.body)
          body['text'].include?('Banque de France - Bilans')
        end).to have_been_requested
      end

      it 'includes reminder text in message' do
        perform_job

        expect(stubbed_mattermost_request.with do |req|
          body = JSON.parse(req.body)
          body['text'].include?('Reminder:')
        end).to have_been_requested
      end

      it 'includes dev handles in message' do
        perform_job

        expect(stubbed_mattermost_request.with do |req|
          body = JSON.parse(req.body)
          body['text'].include?('@samuel')
        end).to have_been_requested
      end
    end

    context 'when no monitors are down' do
      before do
        stub_hyperping_request_operational('entreprise')
        stub_hyperping_request_operational('particulier')
      end

      it 'does not send alert' do
        perform_job

        expect(stubbed_mattermost_request).not_to have_been_requested
      end
    end
  end
end
