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
      let!(:tokens) do
        [
          token_active,
          token_blacklisted_later,
          token_expired,
          token_blacklisted
        ]
      end

      let!(:token_active) { create(:token, authorization_request:, exp: 70.days.from_now) }
      let!(:token_blacklisted_later) { create(:token, :blacklisted, blacklisted_at: 1.day.from_now, authorization_request:) }
      let!(:authorization_request_active) do
        create(
          :authorization_request,
          :with_demandeur,
          :validated,
          tokens: [token_active, token_blacklisted_later],
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

        tokens.each do |token|
          expect(page).to have_css('#' << dom_id(token))
        end

        expect(page).not_to have_css('#' << dom_id(token_archived))

        expect(page).to have_text('☠️ Expiré')
        expect(page).to have_text('🚫 Banni')
        expect(page).to have_text('🔑 Nouveau jeton à utiliser')

        expect(page).to have_text('Cette demande ayant été archivée, aucun jeton ne peut être demandé')
      end

      it 'displays the button to view the token details' do
        expect(page).to have_css('#' << dom_id(authorization_request_active, :show_token_modal_link))
        expect(page).not_to have_css('#' << dom_id(authorization_request_blacklisted, :show_token_modal_link))
        expect(page).not_to have_css('#' << dom_id(authorization_request_archived, :show_token_modal_link))
      end

      it 'displays the button to prolong the token' do
        expect(page).not_to have_css('#' << dom_id(authorization_request_active, :prolong_token_modal_link))
        expect(page).not_to have_css('#' << dom_id(authorization_request_archived, :prolong_token_modal_link))
      end
    end
  end
end
