require 'rails_helper'

RSpec.describe 'create a token magic link', app: :api_particulier do
  subject do
    visit token_path(token)

    within("##{dom_id(token, :magic_link)}") do
      fill_in 'email', with: email
      click_button
    end
  end

  let(:user) { create(:user) }
  let(:token) { create(:token, :with_api_particulier, :with_scopes) }
  let(:new_magic_link) { MagicLink.find_by(email:) }

  context 'when the user is not logged in' do
    it 'redirects to the login page' do
      visit token_path(token)

      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'when the user is logged in' do
    before { login_as(user) }

    context 'when the current user is the token owner' do
      let(:user) do
        user = create(:user, :demandeur)
        create(:authorization_request, :with_demandeur, demandeur: user, tokens: [token])
        user
      end

      context 'when the email address is valid' do
        let(:email) { 'valid@email.com' }

        it_behaves_like 'it creates a magic link'

        it 'redirects to the user account page' do
          subject

          expect(page).to have_current_path(token_path(token))
        end

        it 'saves the token_id in the magic link' do
          subject

          expect(new_magic_link.token).to eq(token)
        end
      end

      context 'when the email address is invalid' do
        let(:email) { 'not an email' }

        it_behaves_like 'it aborts magic link'
        it_behaves_like 'display alert', :error

        it 'redirects to the user account page' do
          subject

          expect(page).to have_current_path(token_path(token))
        end
      end

      describe 'with javascript actived', :js do
        it 'displays modal on click' do
          visit token_path(token)
          expect(page).not_to have_css("##{dom_id(token, :magic_link)}")
          click_button dom_id(token, :transfer_modal_button)
          expect(page).to have_css("##{dom_id(token, :magic_link)}")
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

      it_behaves_like 'it aborts magic link'

      it 'returns an error' do
        subject

        expect(page.driver.status_code).to eq(403)
      end
    end
  end
end
