RSpec.describe HealthcheckJob do
  subject(:healthcheck_job) { described_class.perform_now }

  let!(:stubbed_request) do
    stub_request(:head, Rails.application.credentials.healthcheck_url)
  end

  before do
    allow(Rails.env).to receive(:production?).and_return(true)
  end

  context 'when it is the frontal app' do
    before do
      ENV['FRONTAL'] = 'true'
    end

    it 'calls the healthcheck url' do
      healthcheck_job

      expect(stubbed_request).to have_been_requested
    end
  end

  context 'when it is not the frontal app' do
    before do
      ENV['FRONTAL'] = 'false'
    end

    it 'does not call the healthcheck url' do
      healthcheck_job

      expect(stubbed_request).not_to have_been_requested
    end
  end
end
