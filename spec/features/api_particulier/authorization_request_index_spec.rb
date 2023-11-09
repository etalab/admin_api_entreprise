RSpec.describe 'displays authorization requests', app: :api_particulier do
  subject(:go_to_authorization_requests_index) do
    visit api_particulier_authorization_requests_list_path
  end

  let!(:authenticated_user) { create(:user, :demandeur, :contact_technique, :contact_metier) }
  let!(:non_authenticated_user) { create(:user, :demandeur) }
  let!(:authorization_request) do
    create(
      :authorization_request,
      demandeur_authorization_request_role: non_authenticated_user.user_authorization_request_roles.first,
      api: 'entreprise'
    )
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

    it 'displays the page' do
      expect(page).to have_current_path(api_particulier_authorization_requests_list_path, ignore_query: true)
    end
  end
end
