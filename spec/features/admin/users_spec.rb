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
end
