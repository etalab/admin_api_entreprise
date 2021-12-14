require 'rails_helper'

RSpec.describe 'create a magic link', type: :feature do
  let(:token) { create(:jwt_api_entreprise) }

  before { login_as(user) }

  subject do
    visit user_tokens_path
    within("#" + dom_id(token, :magic_link)) do
      fill_in 'email', with: email
      click_button
    end
  end

  context 'when the current user is the token owner' do
    let(:user) do
      user = create(:user)
      user.authorization_requests << token.authorization_request
      user
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
  end

  context 'when the current user is not the token owner' do
    let(:user) { create(:user) }
    let(:email) { 'valid@email.com' }

    subject do
      page.driver.post(token_create_magic_link_path(token), params: {
        email: 'much@hack.ack'
      })
    end

    it 'does not send the magic link email' do
      expect { subject }
        .not_to have_enqueued_mail(JwtAPIEntrepriseMailer, :magic_link)
    end

    it 'returns an error' do
      subject

      expect(page.driver.status_code).to eq(403)
    end
  end

  context 'when the current user is an admin' do
    let(:user) { create(:user, :admin) }
    let(:email) { 'valid@email.com' }

    subject do
      visit admin_token_path(token)
      within("#" + dom_id(token, :magic_link)) do
        fill_in 'email', with: email
        click_button
      end
    end

    it_behaves_like :it_creates_a_magic_link
  end

  describe 'with javascript actived', js: true do
    let(:user) { create(:user, :with_jwt) }
    let(:token) { user.jwt_api_entreprise.sample }

    it 'works' do
      visit user_tokens_path
      expect(page).not_to have_css('#' + dom_id(token, :magic_link))
      click_on dom_id(token, :modal_button)
      expect(page).to have_css('#' + dom_id(token, :magic_link))
    end
  end
end
