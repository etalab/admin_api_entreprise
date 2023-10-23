RSpec.describe StatusPage, type: :service do
  describe '#current_status' do
    subject(:retrieve_current_status) { described_class.new(namespace).current_status }

    let(:namespace) { "api_#{api}" }
    let(:api) { 'entreprise' }
    let(:hyperping_config_url) { "https://api-#{api}.hyperping.app/api/config?hostname=api-#{api}.hyperping.app" }
    let(:stubbed_request) do
      stub_request(:get, hyperping_config_url).to_return(
        status: 200,
        body: {
          globals: {
            topLevelStatus: {
              status:
            }
          }
        }.to_json
      )
    end
    let(:status) { 'up' }

    before do
      stubbed_request
    end

    context 'without cache set' do
      it 'calls Hyperping url' do
        retrieve_current_status

        expect(stubbed_request).to have_been_requested
      end

      it 'stores value in cache' do
        expect {
          retrieve_current_status
        }.to change { Rails.cache.read("#{namespace}_status_page_current_status") }.to('up')
      end

      context 'when Hyperping works' do
        context 'when it is up' do
          let(:status) { 'up' }

          it { is_expected.to eq(:up) }
        end

        context 'when there are issues' do
          let(:status) { 'outage' }

          it { is_expected.to eq(:has_issues) }
        end

        context 'when it is under maintenance' do
          let(:status) { 'maintenance' }

          it { is_expected.to eq(:maintenance) }
        end
      end

      context 'when Hyperping does not work' do
        let(:stubbed_request) do
          stub_request(:get, hyperping_config_url).to_timeout
        end

        it { is_expected.to eq(:undefined) }
      end
    end

    context 'with cache set' do
      before do
        Rails.cache.write("#{namespace}_status_page_current_status", status)
      end

      it 'does not call Hyperping' do
        retrieve_current_status

        expect(stubbed_request).not_to have_been_requested
      end

      it 'retrieves the status from cache' do
        expect(subject).to eq(:up)
      end
    end
  end
end
