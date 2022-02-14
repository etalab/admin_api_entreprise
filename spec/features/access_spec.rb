require 'rails_helper'

RSpec.describe 'page access', type: :feature do
  context 'when the user is not logged in' do
    it 'can access the login page' do
      visit login_path

      expect(page).to have_current_path(login_path, ignore_query: true)
    end

    context 'when the user tries to access a restricted page' do
      before { visit admin_users_path }

      it 'is redirected to the login page' do
        expect(page).to have_current_path(login_path, ignore_query: true)
      end

      it_behaves_like 'display alert', :error
    end
  end

  context 'when the user is logged in' do
    before { login_as(user) }

    context 'when the user is an admin' do
      let(:user) { create(:user, :admin) }

      it 'is redirected to the user index while accessing the login page' do
        visit login_path

        expect(page).to have_current_path(admin_users_path, ignore_query: true)
      end

      it 'can access pages with an access restricted to admins' do
        visit admin_users_path

        expect(page).to have_current_path(admin_users_path, ignore_query: true)
      end
    end

    context 'when the user is a regular user' do
      let(:user) { create(:user) }

      it 'is redirected to the user details while accessing the login page' do
        visit login_path

        expect(page).to have_current_path(user_profile_path, ignore_query: true)
      end

      it 'is redirected to the user details while accessing an admin page' do
        visit admin_users_path

        expect(page).to have_current_path(user_profile_path, ignore_query: true)
      end
    end
  end
end
