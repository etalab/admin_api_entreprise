RSpec.describe 'displays prolong token content' do
  subject(:got_to_prolong_token_page) do
    visit token_prolong_path(id: token.id)
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
    got_to_prolong_token_page
  end

  describe 'when token is not found', app: :api_entreprise do
    let!(:token) do
      create(:token)
    end

    it 'redirects to the profile' do
      expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
    end
  end

  describe 'when the token cannot be prolonged', app: :api_entreprise do
    describe 'when the user is not demandeur' do
      let!(:authorization_request) do
        create(
          :authorization_request,
          :with_contact_metier,
          contact_metier: authenticated_user,
          api: 'entreprise',
          status: 'validated'
        )
      end
      let!(:token) do
        create(:token, authorization_request:)
      end

      it 'redirects to the profile' do
        expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
      end
    end

    describe 'when token has more than 90 days left' do
      let!(:token) do
        create(:token, authorization_request:, exp: 93.days.from_now.to_i)
      end

      it 'redirects to the profile' do
        expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
      end
    end
  end

  describe 'when the token can be prolonged', app: :api_entreprise do
    let!(:token) do
      create(:token, authorization_request:, exp: 83.days.from_now.to_i)
    end

    it 'displays the page' do
      expect(page).to have_current_path(token_prolong_path(id: token.id), ignore_query: true)

      click_link('prolong_form_link')
    end
  end
end
