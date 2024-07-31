# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Particulier', app: :api_particulier do
  subject(:visit_dashboard) do
    visit api_particulier_dashboard_reporter_path
  end

  before do
    login_as(user)
  end

  context 'with valid user' do
    let(:user) { create(:user, email: 'user@yopmail.com') }

    it 'renders metabase view and groups associated to this user' do
      visit_dashboard

      expect(page).to have_current_path(api_particulier_dashboard_reporter_path)

      expect(page.html).to include('metabase.entreprise.api.gouv.fr')

      expect(page).to have_content('Quotient Familial')
      expect(page).to have_no_content('France travail')
    end
  end

  context 'with admin user' do
    let(:user) { create(:user, email: 'admin@beta.gouv.fr') }

    it 'renders metabase view and all groups' do
      visit_dashboard

      expect(page).to have_current_path(api_particulier_dashboard_reporter_path)

      expect(page.html).to include('metabase.entreprise.api.gouv.fr')

      expect(page).to have_content('Quotient Familial')
      expect(page).to have_content('France travail')
    end
  end

  context 'with invalid user' do
    let(:user) { create(:user, email: 'unknown@yopmail.com') }

    it 'redirects to root path' do
      visit_dashboard

      expect(page).to have_current_path(root_path)
    end
  end
end
