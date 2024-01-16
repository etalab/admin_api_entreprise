RSpec.describe 'Admin: access', app: :api_entreprise do
  subject(:visit_admin) do
    visit admin_users_path
  end

  context 'without user' do
    it 'redirects to login path' do
      visit_admin

      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'with user' do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end

    it 'redirects to root' do
      visit_admin

      expect(page).to have_current_path(root_path, ignore_query: true)
    end
  end

  context 'with admin' do
    let(:user) { create(:user, :admin) }

    before do
      login_as(user)
    end

    it 'does not redirect to root' do
      visit_admin

      expect(page).to have_current_path(admin_users_path, ignore_query: true)
    end
  end
end
