RSpec.describe UpdateOrganizationINSEEPayloadJob do
  subject(:update_organization_insee_payload_job) { described_class.perform_now(organization_id) }

  context 'with invalid organization' do
    let(:organization_id) { 0 }

    it 'does not call the API' do
      expect(INSEESireneAPIClient).not_to receive(:new)

      update_organization_insee_payload_job
    end
  end

  context 'with valid organization' do
    let(:organization_id) { organization.id }

    let(:insee_sirene_api_client) { instance_double(INSEESireneAPIClient, etablissement: insee_sirene_api_etablissement_payload) }
    let(:insee_sirene_api_etablissement_payload) { insee_sirene_api_etablissement_valid_payload(siret: organization.siret) }

    before do
      allow(INSEESireneAPIClient).to receive(:new).and_return(insee_sirene_api_client)
    end

    context 'when organization has been recently updated for his INSEE payload' do
      let(:organization) { create(:organization, last_insee_payload_updated_at: 1.hour.ago) }

      it 'does not call the API' do
        expect(insee_sirene_api_client).not_to receive(:etablissement)

        update_organization_insee_payload_job
      end
    end

    context 'when organization has not been recently updated for his INSEE payload' do
      let(:organization) { create(:organization, last_insee_payload_updated_at: 42.days.ago) }

      it 'calls the API' do
        expect(insee_sirene_api_client).to receive(:etablissement).with(siret: organization.siret)

        update_organization_insee_payload_job
      end

      it 'updates the organization with the payload' do
        update_organization_insee_payload_job

        expect(organization.reload.insee_payload).to eq(insee_sirene_api_etablissement_payload)
      end

      it "updates the organization's last INSEE payload updated at with the current time" do
        update_organization_insee_payload_job

        expect(organization.reload.last_insee_payload_updated_at).to be_within(1.second).of(Time.current)
      end
    end
  end
end
