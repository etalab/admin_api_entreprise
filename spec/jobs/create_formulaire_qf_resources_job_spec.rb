require 'rails_helper'

RSpec.describe CreateFormulaireQFResourcesJob do
  describe '#perform' do
    subject do
      described_class.perform_now(authorization_request_id)
    end

    let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique) }
    let(:authorization_request_id) { authorization_request.id }

    before do
      allow(DatapassWebhook::CreateFormulaireQFResources).to receive(:call).with(authorization_request:)
    end

    it 'creates FormulaireQF resources' do
      subject

      expect(DatapassWebhook::CreateFormulaireQFResources).to have_received(:call).with(authorization_request:)
    end
  end
end
