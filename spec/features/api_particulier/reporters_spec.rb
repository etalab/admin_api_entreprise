# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API Particulier', app: :api_particulier do
  subject(:visit_dashboard) do
    visit api_particulier_dashboard_reporter_path(id:)
  end

  before do
    login_as(user)
  end

  context 'with valid user and id' do
    let(:id) { 'cnaf' }
    let(:user) { create(:user, email: 'user@yopmail.com') }

    it 'renders metabase view' do
      visit_dashboard

      expect(page).to have_current_path(api_particulier_dashboard_reporter_path(id:))
      expect(page.html).to include('metabase.entreprise.api.gouv.fr')
    end
  end

  context 'with invalid user' do
    let(:id) { 'cnaf' }
    let(:user) { create(:user, email: 'datapass@yopmail.com') }

    it 'redirects to root path' do
      visit_dashboard

      expect(page).to have_current_path(root_path)
    end
  end

  context 'with invalid id' do
    let(:id) { 'whatever' }
    let(:user) { create(:user, email: 'user@yopmail.com') }

    it 'redirects to root path' do
      visit_dashboard

      expect(page).to have_current_path(root_path)
    end
  end
end
