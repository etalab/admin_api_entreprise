RSpec.describe 'displays authorization requests', app: :api_particulier do
  subject(:go_to_authorization_requests_index) do
    visit api_particulier_authorization_requests_list_path
  end

  let!(:authenticated_user) { create(:user) }
  let!(:non_authenticated_user) { create(:user, :demandeur) }

  let!(:authorization_request) do
    create(
      :authorization_request,
      :with_demandeur,
      demandeur: non_authenticated_user,
      api: 'entreprise'
    )
  end

  let!(:authorization_request_active) { nil }
  let!(:authorization_request_expired) { nil }
  let!(:authorization_request_blacklisted) { nil }
  let!(:authorization_request_archived) { nil }
  let!(:authorization_requests) do
    [
      authorization_request_active,
      authorization_request_expired,
      authorization_request_blacklisted,
      authorization_request_archived
    ]
  end

  let!(:token) do
    create(:token, authorization_request:)
  end

  describe 'when user is not authenticated' do
    it 'redirects to the login' do
      go_to_authorization_requests_index
      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end
  end

  describe 'when user is authenticated' do
    before do
      login_as(authenticated_user)
      go_to_authorization_requests_index
    end

    describe 'when the user does not have authorization requests' do
      it 'displays the page' do
        expect(page).to have_current_path(api_particulier_authorization_requests_list_path, ignore_query: true)

        expect(page).to have_content("Vous n'avez aucune habilitations")
      end
    end

    describe 'when the user has authorization requests' do
      let!(:token_active) { create(:token, authorization_request:) }
      let!(:authorization_request_active) do
        create(
          :authorization_request,
          :with_demandeur,
          :validated,
          tokens: [token_active],
          demandeur: authenticated_user,
          api: 'particulier'
        )
      end

      let!(:token_expired) { create(:token, :expired, authorization_request:) }
      let!(:authorization_request_expired) do
        create(
          :authorization_request,
          :with_demandeur,
          :validated,
          tokens: [token_expired],
          demandeur: authenticated_user,
          api: 'particulier'
        )
      end

      let!(:token_blacklisted) { create(:token, :blacklisted, authorization_request:) }
      let!(:authorization_request_blacklisted) do
        create(
          :authorization_request,
          :with_demandeur,
          :validated,
          tokens: [token_blacklisted],
          demandeur: authenticated_user,
          api: 'particulier'
        )
      end

      let!(:token_archived) { create(:token, authorization_request:) }
      let!(:authorization_request_archived) do
        create(
          :authorization_request,
          :with_demandeur,
          :submitted,
          status: 'archived',
          tokens: [token_archived],
          demandeur: authenticated_user,
          api: 'particulier'
        )
      end

      it 'displays the page' do
        expect(page).to have_current_path(api_particulier_authorization_requests_list_path, ignore_query: true)

        expect(page).to have_content('Habilitations API Particulier (4)')

        authorization_requests.each do |ar|
          expect(page).to have_css('#' << dom_id(ar))
        end

        expect(page).to have_text('☠️ Expiré')
        expect(page).to have_text('🚫 Banni')
        expect(page).to have_text('🔑 Nouveau jeton à utiliser')

        expect(page).to have_text('Cette demande ayant été archivée, aucun jeton ne peut être demandé')
      end
    end
  end
end
