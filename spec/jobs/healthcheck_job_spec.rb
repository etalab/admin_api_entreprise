RSpec.describe HealthcheckJob do
  subject(:healthcheck_job) { described_class.perform_now }

  let!(:stubbed_request) do
    stub_request(:head, /#{Rails.application.credentials.healthcheck_url}/)
  end

  it 'calls the healthcheck url' do
    healthcheck_job

    expect(stubbed_request).to have_been_requested
  end
end
