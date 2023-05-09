require 'rails_helper'

RSpec.describe 'page access', app: :api_entreprise do
  context 'when the user is not logged in' do
    before { visit login_path }

    it 'can access the login page' do
      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'when the user is logged in' do
    describe 'when user is demandeur' do
      let(:user) { create(:user, :demandeur) }

      before { login_as(user) }

      it 'is redirected to the user details while accessing the login page' do
        visit login_path

        expect(page).to have_current_path(user_profile_path, ignore_query: true)
      end
    end

    describe 'non-regression test: when user is contact_technique' do
      let(:user) { create(:user, :contact_metier) }

      before { login_as(user) }

      it 'is redirected to the user details while accessing the login page' do
        visit login_path

        expect(page).to have_current_path(user_profile_path, ignore_query: true)
      end
    end
  end
end
