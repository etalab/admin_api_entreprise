RSpec.describe 'Admin: users', app: :api_entreprise do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  describe 'impersonification' do
    subject(:impersonate) do
      visit admin_users_path

      click_on dom_id(user, :impersonate)
    end

    let!(:user) { create(:user) }

    it 'redirects to home page as the user, with a warning' do
      impersonate

      expect(page).to have_content("connecté en tant que #{user.email}")
      expect(page).to have_current_path(root_path)
    end
  end

  describe 'search' do
    subject(:search) do
      visit admin_users_path

      fill_in 'search_main_input', with: valid_user.email

      click_on 'Rechercher'
    end

    let!(:valid_user) { create(:user) }
    let!(:invalid_user) { create(:user) }

    it 'displays the valid user' do
      search

      expect(page).to have_css('.user', count: 1)
      expect(page).to have_content(valid_user.email)
      expect(page).to have_no_content(invalid_user.email)
    end
  end
end
