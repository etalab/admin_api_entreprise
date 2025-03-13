RSpec.describe 'Admin: provider dashboards', app: :api_entreprise do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  describe 'index page' do
    it 'displays the providers list linked to API Entreprise' do
      visit admin_provider_dashboards_path

      expect(page).to have_content('Tableaux de bords des fournisseurs')

      expect(page).to have_content('INSEE')
      expect(page).to have_no_content('France Travail')
    end
  end

  describe 'show page' do
    it 'renders the provider dashboard page' do
      visit admin_provider_dashboards_path

      first(:link, 'Tableau de bord').click

      expect(page).to have_css('h1')
      expect(page).to have_css('iframe')
    end
  end
end
