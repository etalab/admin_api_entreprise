RSpec.describe 'displays the token', app: :api_particulier do
  subject(:got_to_show_token_page) do
    visit api_particulier_token_path(id: token.id)
  end

  let!(:authenticated_user) { create(:user, :demandeur, :contact_technique, :contact_metier) }
  let!(:authorization_request) do
    create(
      :authorization_request,
      :with_demandeur,
      demandeur: authenticated_user,
      api: 'entreprise',
      status: 'validated'
    )
  end

  before do
    login_as(authenticated_user)
    got_to_show_token_page
  end

  describe 'when token is not found' do
    let!(:token) do
      create(:token)
    end

    it 'redirects to the profile' do
      expect(page).to have_current_path(api_particulier_authorization_requests_path, ignore_query: true)
    end
  end

  describe 'when the tokens show cannot be seen' do
    describe 'when the user is not demandeur' do
      let!(:authorization_request) do
        create(
          :authorization_request,
          :with_demandeur,
          :with_contact_technique,
          :with_contact_metier,
          contact_metier: authenticated_user,
          api: 'entreprise',
          status: 'validated'
        )
      end
      let!(:token) do
        create(:token, authorization_request:)
      end

      it 'displays the page' do
        expect(page).to have_current_path(api_particulier_token_path(id: token.id), ignore_query: true)

        expect(page).to have_content('Contact principal')
      end
    end
  end

  describe 'when the token can be showed' do
    let!(:token) do
      create(:token, authorization_request:)
    end

    it 'displays the page' do
      expect(page).to have_current_path(api_particulier_token_path(id: token.id), ignore_query: true)

      expect(page).to have_content("Jeton d'accès")
    end
  end
end
