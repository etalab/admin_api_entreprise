require 'rails_helper'

RSpec.describe DatapassWebhook::APIParticulier::CreateHubEEOrganization, type: :interactor do
  subject(:interactor) { described_class.call(**params) }

  let(:authorization_request) { create(:authorization_request, :with_demandeur) }
  let(:hubee_api_client) { instance_double(HubEEAPIClient) }
  let(:params) { { authorization_request: } }
  let(:stripped_organization_payload) { { 'companyRegister' => '123456789', 'branchCode' => '123456' } }

  context 'when everything works as expected' do
    before do
      allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
      allow(hubee_api_client).to receive(:find_or_create_organization).and_return(stripped_organization_payload)
    end

    it 'finds or creates an HubEE organization' do
      expect(hubee_api_client).to receive(:find_or_create_organization).with(authorization_request.organization, authorization_request.demandeur.email)
      interactor
    end

    it 'saves the HubEE organization id to the authorization request' do
      expect {
        interactor
      }.to change { authorization_request.reload.extra_infos['hubee_organization_id'] }.from(nil).to('SI-123456789-123456')
    end

    it 'adds the HubEE organization payload to the context' do
      expect(interactor.hubee_organization_payload).to eq(stripped_organization_payload)
    end

    it { is_expected.to be_a_success }
  end

  context 'when HubEE raises an error' do
    before do
      allow(HubEEAPIClient).to receive(:new).and_return(hubee_api_client)
      allow(hubee_api_client).to receive(:find_or_create_organization).and_raise(Faraday::BadRequestError)
    end

    it 'raises an error' do
      expect {
        interactor
      }.to raise_error(Faraday::BadRequestError)
    end
  end
end
