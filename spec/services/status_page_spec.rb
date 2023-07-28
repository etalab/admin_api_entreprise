RSpec.describe StatusPage, type: :service do
  describe '#current_status' do
    subject(:retrieve_current_status) { described_class.new.current_status }

    let(:instatus_url) { 'https://status.entreprise.api.gouv.fr/summary.json' }
    let(:stubbed_request) do
      stub_request(:get, instatus_url).to_return(
        status: 200,
        body: {
          page: {
            status:
          }
        }.to_json
      )
    end
    let(:status) { 'UP' }

    before do
      stubbed_request
    end

    context 'without cache set' do
      it 'calls Instatus url' do
        retrieve_current_status

        expect(stubbed_request).to have_been_requested
      end

      it 'stores value in cache' do
        expect {
          retrieve_current_status
        }.to change { Rails.cache.read('status_page_current_status') }.to('UP')
      end

      context 'when Instatus works' do
        context 'when it is up' do
          let(:status) { 'UP' }

          it { is_expected.to eq(:up) }
        end

        context 'when there are issues' do
          let(:status) { 'HASISSUES' }

          it { is_expected.to eq(:has_issues) }
        end

        context 'when it is under maintenance' do
          let(:status) { 'UNDERMAINTENANCE' }

          it { is_expected.to eq(:maintenance) }
        end
      end

      context 'when Instatus does not work' do
        let(:stubbed_request) do
          stub_request(:get, instatus_url).to_timeout
        end

        it { is_expected.to eq(:undefined) }
      end
    end

    context 'with cache set' do
      before do
        Rails.cache.write('status_page_current_status', status)
      end

      it 'does not call Instatus' do
        retrieve_current_status

        expect(stubbed_request).not_to have_been_requested
      end

      it 'retrieves the status from cache' do
        expect(subject).to eq(:up)
      end
    end
  end
end
