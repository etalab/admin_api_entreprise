RSpec.describe 'displays authorization requests', app: :api_particulier do
  subject(:go_to_authorization_requests_show) do
    visit api_particulier_authorization_requests_show_path(id: authorization_request.id)
  end

  let!(:authenticated_user) { create(:user, :demandeur) }
  let!(:non_authenticated_user) { create(:user, :demandeur) }
  let!(:authorization_request) do
    create(
      :authorization_request,
      demandeur_authorization_request_role: non_authenticated_user.user_authorization_request_roles.first,
      api: 'entreprise'
    )
  end

  describe 'when user is not authenticated' do
    it 'redirects to the login' do
      go_to_authorization_requests_show
      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end
  end

  describe 'when user is authenticated' do
    before do
      login_as(authenticated_user)
      go_to_authorization_requests_show
    end

    describe 'when authorization_request does not belong to current_user' do
      it 'redirects to the profile' do
        expect(page).to have_current_path(api_particulier_user_profile_path, ignore_query: true)
      end
    end

    describe 'when authorization_request belongs to current_user' do
      describe 'when it not viewable by users' do
        let!(:authorization_request) do
          create(
            :authorization_request,
            demandeur_authorization_request_role: authenticated_user.user_authorization_request_roles.first,
            api: 'entreprise',
            status: 'draft'
          )
        end

        it 'redirects to the profile' do
          expect(page).to have_current_path(api_particulier_user_profile_path, ignore_query: true)
        end
      end

      describe 'when authorization_request is from api_entreprise' do
        let!(:authorization_request) do
          create(
            :authorization_request,
            demandeur_authorization_request_role: authenticated_user.user_authorization_request_roles.first,
            api: 'entreprise',
            status: 'validated'
          )
        end

        it 'redirects to the profile' do
          expect(page).to have_current_path(api_particulier_user_profile_path, ignore_query: true)
        end
      end

      describe 'when authorization_request is from api_particulier' do
        describe 'when the authorization request is valid' do
          let!(:authorization_request) do
            create(
              :authorization_request,
              demandeur_authorization_request_role: authenticated_user.user_authorization_request_roles.first,
              api: 'particulier'
            )
          end

          it 'diplays the page' do
            expect(page).to have_current_path(api_particulier_authorization_requests_show_path(id: authorization_request.id), ignore_query: true)
          end
        end
      end
    end
  end
end
