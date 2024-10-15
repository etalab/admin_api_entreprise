require 'rails_helper'

RSpec.describe DatapassWebhook::APIParticulier::CreateFormulaireQFCollectivity, type: :interactor do
  subject(:interactor) { described_class.call(**params) }

  let(:authorization_request) { create(:authorization_request) }
  let(:formulaire_qf_api_client) { instance_double(FormulaireQFAPIClient) }
  let(:params) { { authorization_request: } }
  let(:organization) { authorization_request.organization }
  let(:editor_id) { 'SUPEREDITOR' }

  before do
    allow(FormulaireQFAPIClient).to receive(:new).and_return(formulaire_qf_api_client)
    allow(formulaire_qf_api_client).to receive(:create_collectivity)

    authorization_request.extra_infos['service_provider'] = { 'id' => editor_id }
  end

  it 'creates a collectivity on FormulaireQF' do
    expect(formulaire_qf_api_client).to receive(:create_collectivity).with(organization:, editor_id:)
    interactor
  end

  it { is_expected.to be_a_success }
end
