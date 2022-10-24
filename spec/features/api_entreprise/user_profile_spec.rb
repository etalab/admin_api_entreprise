require 'rails_helper'

RSpec.describe 'user profile page', app: :api_entreprise do
  subject(:show_profile) { visit user_profile_path }

  let(:user) { create(:user, :with_note) }

  let(:invalid_authorization_request) { create(:authorization_request, user:) }
  let(:valid_authorization_request) { create(:authorization_request, :submitted, user:) }

  context 'when the user is not authenticated' do
    it 'redirects to the login' do
      show_profile

      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'when the user is authenticated' do
    before do
      login_as(user)
    end

    it 'displays the user infos' do
      show_profile

      expect(page).to have_content(user.email)
    end

    it 'does not display the user note' do
      show_profile

      expect(page).not_to have_content(user.note)
    end

    it 'has a button to transfer the account ownership' do
      show_profile

      expect(page).to have_css('#transfer_account_button')
    end

    it 'displays authorizations requests which are submitted', js: true do
      valid_authorization_request
      invalid_authorization_request

      show_profile

      expect(page).to have_css("##{dom_id(valid_authorization_request, :list)}")
      expect(page).not_to have_css("##{dom_id(invalid_authorization_request, :list)}")
    end
  end
end
