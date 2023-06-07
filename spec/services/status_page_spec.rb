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
    let(:redis_service) { RedisService.instance }
    let(:status) { 'UP' }

    before do
      redis_service.del('status_page_current_status')
      stubbed_request
    end

    context 'without cache set' do
      it 'calls Instatus url' do
        retrieve_current_status

        expect(stubbed_request).to have_been_requested
      end

      it 'stores value in redis_service' do
        expect {
          retrieve_current_status
        }.to change { redis_service.get('status_page_current_status') }.to('UP')
      end

      it 'sets a ttl of 5 minutes on redis_service key' do
        retrieve_current_status

        expect(redis_service.ttl('status_page_current_status')).to be_within(5.seconds.to_i).of(5.minutes.to_i)
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
        redis_service.set('status_page_current_status', status)
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
