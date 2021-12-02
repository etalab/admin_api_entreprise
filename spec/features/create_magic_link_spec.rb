require 'rails_helper'

RSpec.describe 'create a magic link', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  let(:token) { user.jwt_api_entreprise.take }

  before { login_as(user) }

  subject do
    visit user_tokens_path
    within("#" + dom_id(token, :magic_link)) do
      fill_in 'email', with: email
      click_button
    end
  end

  context 'when the email address is valid' do
    let(:email) { 'valid@email.com' }

    it_behaves_like :it_creates_a_magic_link

    it 'redirects to the user token index page' do
      subject

      expect(page).to have_current_path(user_tokens_path)
    end

  end

  context 'when the email address is invalid' do
    let(:email) { 'not an email' }

    it_behaves_like :it_aborts_magic_link

    it 'redirects to the user token index page' do
      subject

      expect(page).to have_current_path(user_tokens_path)
    end
  end

  describe 'with javascript actived', js: true do
    it 'works' do
      visit user_tokens_path
      expect(page).not_to have_css('#' + dom_id(token, :magic_link))
      click_on dom_id(token, :modal_button)
      expect(page).to have_css('#' + dom_id(token, :magic_link))
    end
  end
end
