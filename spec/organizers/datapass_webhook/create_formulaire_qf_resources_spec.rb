require 'rails_helper'

RSpec.describe DatapassWebhook::CreateFormulaireQFResources do
  subject(:interactor) { described_class.call(authorization_request:) }

  let(:hubee_api_client) { instance_double(HubEEAPIClient) }
  let(:insee_api_authentication) { instance_double(INSEEAPIAuthentication, access_token: 'access_token') }
  let(:insee_payload) { insee_sirene_api_etablissement_valid_payload(siret: editor_siret, full: true) }
  let(:authorization_request) { create(:authorization_request, :with_demandeur, api: 'particulier') }
  let(:subscription_payload) { hubee_subscription_payload(authorization_request:) }
  let(:editor_siret) { '13002526500013' }
  let(:service_provider) { { 'type' => 'editor', 'siret' => editor_siret } }
  let(:formulaire_qf_api_client) { instance_double(FormulaireQFAPIClient) }
  let(:siret) { '12345678901234' }
  let(:code_commune) { '12345' }

  let(:organization_payload) { hubee_organization_payload(siret:, code_commune:) }

  before do
    allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
    allow(hubee_api_client).to receive_messages(find_or_create_organization: organization_payload, create_subscription: subscription_payload)
    allow(INSEEAPIAuthentication).to receive(:new).and_return(insee_api_authentication)
    stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3.11/siret/#{editor_siret}").to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: insee_payload.to_json
    )
    allow(FormulaireQFAPIClient).to receive(:new).and_return(formulaire_qf_api_client)
    allow(formulaire_qf_api_client).to receive(:create_collectivity)
  end

  it 'stores the organization id on the authorization request' do
    interactor

    expect(authorization_request.reload.extra_infos['hubee_organization_id']).to eq("SI-#{siret}-#{code_commune}")
  end

  it 'creates a subscription on HubEE' do
    expect(hubee_api_client).to receive(:create_subscription)

    interactor
  end

  it 'stores the subscription id on the authorization request' do
    interactor

    expect(authorization_request.reload.extra_infos['hubee_subscription_id']).to eq(subscription_payload['id'])
  end

  describe 'subscription creation' do
    context 'when subscription failed' do
      before do
        allow(hubee_api_client).to receive(:create_subscription).and_raise(Faraday::Error)
      end

      it { is_expected.to be_a_success }

      it 'captures an error' do
        expect(Sentry).to receive(:set_context).with(
          'DataPass webhook: create FormulaireQF resources',
          payload: { authorization_request_id: authorization_request.id }
        )
        expect(Sentry).to receive(:capture_exception).with(Faraday::Error)
        interactor
      end
    end
  end
end
