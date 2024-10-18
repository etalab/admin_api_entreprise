require 'rails_helper'

RSpec.describe CreateFormulaireQFCollectivityJob do
  describe '#perform' do
    subject(:job) { described_class.perform_now(authorization_request.id) }

    let(:api_client) { instance_double(FormulaireQFAPIClient) }
    let(:authorization_request) { create(:authorization_request, :with_demandeur, api: 'particulier') }

    before do
      allow(FormulaireQFAPIClient).to receive(:new).and_return(api_client)
    end

    it 'creates collectivity on Formulaire QF' do
      expect(api_client).to receive(:create_collectivity).with(authorization_request)

      job
    end
  end
end
