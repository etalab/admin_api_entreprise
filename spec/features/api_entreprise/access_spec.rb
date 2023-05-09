require 'rails_helper'

RSpec.describe 'page access', app: :api_entreprise do
  context 'when the user is not logged in' do
    before { visit login_path }

    it 'can access the login page' do
      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'when the user is logged in' do
    let(:user) { create(:user) }

    before { login_as(user) }

    it 'is redirected to the user details while accessing the login page' do
      visit login_path

      expect(page).to have_current_path(user_profile_path, ignore_query: true)
    end
  end
end
