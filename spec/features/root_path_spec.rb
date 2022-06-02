require 'rails_helper'

RSpec.describe 'Root path', type: :feature do
  subject(:visit_root_path) { visit root_path }

  before do
    Capybara.app_host = "http://#{host}"
  end

  after do
    Capybara.app_host = nil
  end

  context 'when sudomain is dashboard.entreprise.api' do
    let(:host) { 'dashboard.entreprise.api.localhost.me' }

    it 'redirect to /login' do
      visit_root_path

      expect(page).to have_current_path(login_path)
    end
  end

  context 'when subdomain is not dashboard.entreprise.api' do
    let(:host) { 'whatever.localhost.me' }

    it 'renders homepage' do
      visit_root_path

      expect(page).to have_css('#homepage')
    end
  end
end
