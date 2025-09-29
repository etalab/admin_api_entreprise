RSpec.describe 'displays authorization requests', app: :api_particulier do
  subject(:go_to_authorization_requests_index) do
    visit api_particulier_authorization_requests_path
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
    end

    describe 'when the user does not have authorization requests' do
      it 'displays the page' do
        go_to_authorization_requests_index
        expect(page).to have_current_path(api_particulier_authorization_requests_path, ignore_query: true)

        expect(page).to have_content("Vous n'avez aucune habilitation")
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
          intitule: 'active',
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

      let!(:prolong_wizard) { create(:prolong_token_wizard, :requires_update, token: token_active, status:) }
      let!(:status) { 'owner' }

      let!(:approved_authorization_request_without_token) do
        user_authorization_request_role = create(:user_authorization_request_role, authorization_request: create(:authorization_request, :validated, api: :particulier), user: authenticated_user, role: 'contact_technique')
        user_authorization_request_role.authorization_request.tokens.delete_all
        user_authorization_request_role.authorization_request
      end

      it 'displays the page' do
        go_to_authorization_requests_index

        expect(page).to have_current_path(api_particulier_authorization_requests_path, ignore_query: true)

        expect(page).to have_content('Habilitations API Particulier (5)')

        authorization_requests.each do |ar|
          expect(page).to have_css('#' << dom_id(ar))
        end

        tokens.each do |token|
          expect(page).to have_css('#' << dom_id(token))
        end

        within('#' << dom_id(token_archived)) do
          expect(page).to have_text('Aucun jeton actif')
        end

        expect(page).to have_text('☠️ Expiré')
        expect(page).to have_text('🚫 Banni')
        expect(page).to have_text('🔑 Nouveau jeton à utiliser')

        expect(page).to have_text('Cette demande ayant été archivée, aucun jeton ne peut être demandé')
      end

      it 'displays the button to view the token details' do
        go_to_authorization_requests_index

        expect(page).to have_css('#' << dom_id(authorization_request_active, :show_token_modal_link))
        expect(page).to have_no_css('#' << dom_id(authorization_request_blacklisted, :show_token_modal_link))
        expect(page).to have_no_css('#' << dom_id(authorization_request_archived, :show_token_modal_link))
      end

      describe 'displays the button to prolong the token' do
        it 'displays the button to prolong the token' do
          go_to_authorization_requests_index

          expect(page).to have_css('#' << dom_id(authorization_request_active, :prolong_token_modal_link))
          expect(page).to have_no_css('#' << dom_id(authorization_request_archived, :prolong_token_modal_link))
        end

        describe 'when there is no prolong wizard' do
          it 'displays the default label' do
            go_to_authorization_requests_index

            expect(page).to have_text('Prolonger le jeton')
          end
        end

        describe 'when there is a requires update prolong wizard' do
          let!(:status) { 'requires_update' }

          it 'displays the correct label' do
            go_to_authorization_requests_index

            expect(page).to have_text('Terminer la mise à jour')
          end
        end

        describe 'when there is a changes requested prolong wizard' do
          let!(:status) { 'updates_requested' }

          it 'displays the correct label' do
            go_to_authorization_requests_index

            expect(page).to have_text('Demande de mise à jour')
          end
        end
      end
    end
  end
end
