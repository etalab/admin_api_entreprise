require 'rails_helper'

RSpec.describe DatapassWebhook::APIParticulier::CreateHubEESubscription, type: :interactor do
  subject(:interactor) { described_class.call(**params) }

  let(:authorization_request) { create(:authorization_request) }
  let(:hubee_api_client) { instance_double(HubEEAPIClient) }
  let(:stripped_hubee_organization_payload) { { 'branchCode' => '132456', 'companyRegister' => '123456789', 'id' => '123456789' } }
  let(:stripped_hubee_subscription_payload) { { 'id' => 'ABC123456789' } }
  let(:params) { { authorization_request:, hubee_organization_payload: stripped_hubee_organization_payload } }

  context 'when everything works as expected' do
    before do
      allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
      allow(hubee_api_client).to receive(:create_subscription).and_return(stripped_hubee_subscription_payload)
    end

    context 'when the authorization request has a service provider' do
      let(:authorization_request) { create(:authorization_request, extra_infos: { 'service_provider' => service_provider }) }
      let(:editor_siret) { '13002526500013' }
      let(:service_provider) { { 'type' => 'editor', 'siret' => editor_siret } }

      context 'when the service provider is an editor' do
        let(:insee_api_authentication) { instance_double(INSEEAPIAuthentication, access_token: 'access_token') }
        let(:insee_payload) { insee_sirene_api_etablissement_valid_payload(siret: editor_siret, full: true) }

        before do
          allow(INSEEAPIAuthentication).to receive(:new).and_return(insee_api_authentication)
          stub_request(:get, "https://api.insee.fr/entreprises/sirene/V3.11/siret/#{editor_siret}").to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: insee_payload.to_json
          )
        end

        it 'creates a subscription on HubEE with the editor payload' do
          expect(hubee_api_client).to receive(:create_subscription).with(authorization_request, stripped_hubee_organization_payload, 'FormulaireQF', { delegationActor: { branchCode: '75107', companyRegister: '13002526500013', type: 'EDT' }, accessMode: 'API' })
          interactor
        end
      end

      context 'when the service provider is not an editor' do
        let(:service_provider) { { 'type' => 'service', 'siret' => '123456' } }

        it 'creates a subscription on HubEE without the editor payload' do
          expect(hubee_api_client).to receive(:create_subscription).with(authorization_request, stripped_hubee_organization_payload, 'FormulaireQF', {})
          interactor
        end
      end
    end

    context 'when the authorization request does not have a service provider' do
      it 'creates a subscription on HubEE' do
        expect(hubee_api_client).to receive(:create_subscription).with(authorization_request, stripped_hubee_organization_payload, 'FormulaireQF', {})
        interactor
      end
    end

    it 'saves the HubEE subscription id to the authorization request' do
      expect {
        interactor
      }.to change { authorization_request.reload.extra_infos['hubee_subscription_id'] }.from(nil).to('ABC123456789')
    end

    it 'adds the HubEE subscription payload to the context' do
      expect(interactor.hubee_subscription_payload).to eq(stripped_hubee_subscription_payload)
    end

    it { is_expected.to be_a_success }
  end

  context 'when HubEE raises an error' do
    before do
      allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
      allow(hubee_api_client).to receive(:create_subscription).and_raise(Faraday::BadRequestError)
    end

    it 'raises an error' do
      expect { interactor }.to raise_error(Faraday::BadRequestError)
    end
  end
end
