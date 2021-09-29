require 'rails_helper'

RSpec.describe 'user show page', type: :feature do
  let(:user) { create(:user) }
  subject(:show_user) { visit user_path(user.id) }

  context 'when the user is not authenticated' do
    it 'redirects to the login' do
      show_user

      expect(page.current_path).to eq(login_path)
    end
  end

  context 'when the user is authenticated' do
    before { login_as(authenticated_user) }

    context 'when another user details are requested' do
      let(:authenticated_user) { create(:user) }

      it 'redirects to the authenticated user details' do
        show_user

        expect(page.current_path).to eq(user_path(authenticated_user.id))
      end
    end

    context 'when own user details are requested' do
      let(:authenticated_user) { user }

      it 'works' do
        show_user

        expect(page.current_path).to eq(user_path(user.id))
      end

      it 'displays the user email' do
        show_user

        expect(page).to have_content(user.email)
      end

      it 'displays the user siret' do
        show_user

        expect(page).to have_content(user.context)
      end

      it 'has a button to transfer the account ownership' do
        show_user

        expect(page).to have_css('#transfer_account')
      end
    end
  end
end
