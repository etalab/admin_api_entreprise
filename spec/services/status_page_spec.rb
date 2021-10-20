RSpec.describe StatusPage, type: :service do
  describe '#current_status' do
    subject { described_class.new.current_status }

    let(:instatus_url) { 'https://status.entreprise.api.gouv.fr/summary.json' }

    context 'when Instatus works' do
      before do
        stub_request(:get, instatus_url).to_return(
          status: 200,
          body: {
            page: {
              status: status
            }
          }.to_json
        )
      end

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
      before do
        stub_request(:get, instatus_url).to_timeout
      end

      it { is_expected.to eq(:undefined) }
    end
  end
end
