RSpec.describe CreateFormulaireQFHubEESubscriptionJob, type: :job do
  describe '#perform' do
    subject(:create_formulaire_qf_hubee_subscription_job) do
      described_class.perform_now(authorization_request.id)
    end

    let(:hubee_api_client) { instance_double(HubEEAPIClient) }
    let(:authorization_request) { create(:authorization_request, :with_demandeur, api: 'particulier') }
    let(:subscription_payload) { hubee_subscription_payload(authorization_request:) }

    before do
      allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
    end

    context 'when organization does not exist on HubEE' do
      let(:organization_payload) { hubee_organization_payload(siret:, code_commune:) }
      let(:siret) { '12345678901234' }
      let(:code_commune) { '12345' }

      before do
        allow(hubee_api_client).to receive(:find_organization).and_raise(HubEEAPIClient::NotFound)
        allow(hubee_api_client).to receive_messages(create_organization: organization_payload, create_subscription: subscription_payload)
      end

      it 'creates an organization on HubEE' do
        expect(hubee_api_client).to receive(:create_organization)

        create_formulaire_qf_hubee_subscription_job
      end

      it 'stores the organization id on the authorization request' do
        create_formulaire_qf_hubee_subscription_job

        expect(authorization_request.reload.extra_infos['hubee_organization_id']).to eq("SI-#{siret}-#{code_commune}")
      end

      it 'creates a subscription on HubEE' do
        expect(hubee_api_client).to receive(:create_subscription)

        create_formulaire_qf_hubee_subscription_job
      end

      it 'stores the subscription id on the authorization request' do
        create_formulaire_qf_hubee_subscription_job

        expect(authorization_request.reload.extra_infos['hubee_subscription_id']).to eq(subscription_payload['id'])
      end
    end

    context 'when organization exists on HubEE' do
      before do
        allow(hubee_api_client).to receive_messages(find_organization: hubee_organization_payload, create_subscription: subscription_payload)
      end

      it 'does not create an organization on HubEE' do
        expect(hubee_api_client).not_to receive(:create_organization)

        create_formulaire_qf_hubee_subscription_job
      end

      it 'creates a subscription on HubEE' do
        expect(hubee_api_client).to receive(:create_subscription)

        create_formulaire_qf_hubee_subscription_job
      end

      it 'stores the subscription id on the authorization request' do
        create_formulaire_qf_hubee_subscription_job

        expect(authorization_request.reload.extra_infos['hubee_subscription_id']).to eq(subscription_payload['id'])
      end
    end

    describe 'subscription creation' do
      before do
        allow(hubee_api_client).to receive(:find_organization).and_return(hubee_organization_payload)
      end

      context 'when subscription already exists' do
        before do
          allow(hubee_api_client).to receive(:create_subscription).and_raise(HubEEAPIClient::AlreadyExists)
        end

        it 'does not raise an error' do
          expect { create_formulaire_qf_hubee_subscription_job }.not_to raise_error
        end
      end

      context 'when subscription failed' do
        before do
          allow(hubee_api_client).to receive(:create_subscription).and_raise(Faraday::Error)
        end

        it 'raises an error' do
          expect { create_formulaire_qf_hubee_subscription_job }.to raise_error(Faraday::Error)
        end
      end
    end
  end
end
