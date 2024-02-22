RSpec.describe 'retrieve and sets the current prolong token' do
  subject(:go_to_prolong_token_start) do
    visit token_prolong_start_path(token_id: token.id)
  end

  let!(:authenticated_user) { create(:user) }
  let!(:non_authenticated_user) { create(:user, :demandeur) }
  let!(:exp) { 88.days.from_now.to_i }

  let!(:authorization_request) do
    create(
      :authorization_request,
      :with_demandeur,
      demandeur: authenticated_user,
      api: 'entreprise',
      status: 'validated'
    )
  end

  let!(:token) do
    create(:token, authorization_request:, exp:)
  end

  describe 'when user is not authenticated', app: :api_entreprise do
    it 'redirects to the login' do
      go_to_prolong_token_start
      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end
  end

  describe 'when user is authenticated', app: :api_entreprise do
    before do
      login_as(authenticated_user)
    end

    describe 'when no prolong token wizard exists' do
      it 'creates a new wizard' do
        go_to_prolong_token_start

        expect(current_url).to include('owner')
      end
    end

    describe 'when a prolong token wizard exists' do
      let!(:prolong_token_wizard) do
        create(:prolong_token_wizard, status:, token:, owner:, project_purpose:, contact_technique:, contact_metier:)
      end

      let(:status) { 'prolonged' }
      let(:owner) { 'watever' }
      let(:project_purpose) { true }
      let(:contact_technique) { true }
      let(:contact_metier) { true }

      describe 'when it was already finished and is renewable' do
        it 'creates a new wizard' do
          go_to_prolong_token_start

          expect(current_url).to include('owner')
        end
      end

      describe 'when it was not finished' do
        let(:status) { 'project_purpose' }

        it 'launches the wizard at current step' do
          go_to_prolong_token_start

          expect(current_url).to include(prolong_token_wizard.status)
        end
      end
    end
  end
end
