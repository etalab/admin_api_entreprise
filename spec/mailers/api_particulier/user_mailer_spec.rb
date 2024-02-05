require 'rails_helper'

RSpec.describe APIParticulier::UserMailer do
  describe '#transfer_ownership' do
    subject { described_class.transfer_ownership(old_owner, new_owner, 'api_particulier') }

    let(:new_owner) { create(:user) }
    let(:old_owner) { create(:user) }

    let!(:authorization_requests) do
      create_list(:authorization_request, 3, :with_tokens, :with_demandeur, demandeur: old_owner, api: 'particulier')
    end

    its(:subject) { is_expected.to eq('API Particulier - Délégation d\'accès') }
    its(:to) { is_expected.to eq([new_owner.email]) }

    describe 'email body' do
      it 'contains the previous owner email address' do
        expect(subject.html_part.decoded).to include(old_owner.email)
        expect(subject.text_part.decoded).to include(old_owner.email)
      end

      it 'notifies the user to login to access his tokens' do
        login_url = 'https://particulier.api.gouv.fr/compte/se-connecter'

        expect(subject.html_part.decoded).to include(login_url)
        expect(subject.text_part.decoded).to include(login_url)
      end

      context 'when the new owner already has an API Gouv account' do
        before { new_owner.oauth_api_gouv_id = '12' }

        it 'informs the user he will need his API Gouv account' do
          expect(subject.html_part.decoded).to include(new_owner.email)
          expect(subject.text_part.decoded).to include(new_owner.email)
        end
      end
    end
  end

  describe '#notify_datapass_for_data_reconciliation' do
    subject { described_class.notify_datapass_for_data_reconciliation(user, 'api_particulier') }

    let(:user) { create(:user) }

    let!(:authorization_requests) do
      create_list(:authorization_request, 3, :with_tokens, :with_demandeur, demandeur: user, api: 'particulier')
    end

    let(:datapass_ids) { user.authorization_requests.for_api('particulier').map(&:external_id).map(&:to_i) }

    its(:subject) { is_expected.to eq('API Particulier - Réconciliation de demandes d\'accès à un nouvel usager') }
    its(:to) { is_expected.to eq(['datapass@api.gouv.fr']) }

    it 'contains the user email address' do
      expect(subject.html_part.decoded).to include(user.email)
      expect(subject.text_part.decoded).to include(user.email)
    end

    it 'contains the user API Gouv ID' do
      expect(subject.html_part.decoded).to include(user.oauth_api_gouv_id.to_s)
      expect(subject.text_part.decoded).to include(user.oauth_api_gouv_id.to_s)
    end

    it 'contains the user\'s datapass IDs' do
      expect(subject.html_part.decoded).to include(datapass_ids.to_s)
      expect(subject.text_part.decoded).to include(datapass_ids.to_s)
    end
  end
end
