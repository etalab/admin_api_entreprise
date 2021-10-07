require 'rails_helper'

RSpec.describe 'page access', type: :feature do
  context 'when the user is not logged in' do
    it 'can access the login page' do
      visit login_path

      expect(page.current_path).to eq(login_path)
    end

    context 'when the user tries to access a restricted page' do
      before { visit admin_users_path }

      it 'is redirected to the login page' do
        expect(page.current_path).to eq(login_path)
      end

      it 'shows an error message' do
        expect(page).to have_css('.alert')
      end
    end
  end

  context 'when the user is logged in' do
    before { login_as(user) }

    context 'when the user is an admin' do
      let(:user) { create(:user, :admin) }

      it 'is redirected to the user index while accessing the login page' do
        visit login_path

        expect(page.current_path).to eq(admin_users_path)
      end

      it 'can access pages with an access restricted to admins' do
        visit admin_users_path

        expect(page.current_path).to eq(admin_users_path)
      end
    end

    context 'when the user is a regular user' do
      let(:user) { create(:user) }

      it 'is redirected to the user details while accessing the login page' do
        visit login_path

        expect(page.current_path).to eq(user_profile_path)
      end

      it 'is redirected to the user details while accessing an admin page' do
        visit admin_users_path

        expect(page.current_path).to eq(user_profile_path)
      end
    end
  end
end
