require 'rails_helper'

RSpec.describe 'create a magic link', type: :feature do
  subject do
    visit user_tokens_path
    within('#' + dom_id(token, :magic_link)) do
      fill_in 'email', with: email
      click_button
    end
  end

  let(:token) { create(:token) }

  before { login_as(user) }

  context 'when the current user is the token owner' do
    let(:user) do
      user = create(:user)
      user.authorization_requests << token.authorization_request
      user
    end

    context 'when the email address is valid' do
      let(:email) { 'valid@email.com' }

      it_behaves_like 'it creates a magic link'

      it 'redirects to the user token index page' do
        subject

        expect(page).to have_current_path(user_tokens_path)
      end
    end

    context 'when the email address is invalid' do
      let(:email) { 'not an email' }

      it_behaves_like 'it aborts magic link'

      it 'redirects to the user token index page' do
        subject

        expect(page).to have_current_path(user_tokens_path)
      end
    end
  end

  context 'when the current user is not the token owner' do
    subject do
      page.driver.post(token_create_magic_link_path(token), params: {
        email: 'much@hack.ack'
      })
    end

    let(:user) { create(:user) }
    let(:email) { 'valid@email.com' }

    it 'does not send the magic link email' do
      expect { subject }
        .not_to have_enqueued_mail(TokenMailer, :magic_link)
    end

    it 'returns an error' do
      subject

      expect(page.driver.status_code).to eq(403)
    end
  end

  describe 'with javascript actived', js: true do
    let(:user) { create(:user, :with_token) }
    let(:token) { user.token.sample }

    it 'works' do
      visit user_tokens_path
      expect(page).not_to have_css('#' + dom_id(token, :magic_link))
      click_on dom_id(token, :modal_button)
      expect(page).to have_css('#' + dom_id(token, :magic_link))
    end
  end
end
