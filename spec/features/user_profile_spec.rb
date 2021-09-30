require 'rails_helper'

RSpec.describe 'user profile page', type: :feature do
  let(:user) { create(:user) }
  subject(:show_profile) { visit user_profile_path }

  context 'when the user is not authenticated' do
    it 'redirects to the login' do
      show_profile

      expect(page.current_path).to eq(login_path)
    end
  end

  context 'when the user is authenticated' do
    before do
      login_as(user)
      show_profile
    end

    it 'displays the user email' do
      expect(page).to have_content(user.email)
    end

    it 'displays the user siret' do
      expect(page).to have_content(user.context)
    end

    it 'has a button to transfer the account ownership' do
      expect(page).to have_css('#transfer_account')
    end
  end
end
