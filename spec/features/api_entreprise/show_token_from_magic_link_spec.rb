require 'rails_helper'

RSpec.describe 'show token from magic link', app: :api_entreprise do
  subject do
    visit token_show_magic_link_path(token: magic_token)
  end

  let!(:user) { create(:user, :with_token, tokens_amount: 2, email:) }
  let(:email) { 'any-email@data.gouv.fr' }

  context 'when the magic link token does not exist' do
    let(:magic_token) { 'wrong token' }

    it_behaves_like 'display alert', :error

    it 'redirects to the login page' do
      subject

      expect(page).to have_current_path(login_path)
    end
  end

  context 'when the magic link token exists' do
    let!(:magic_link) { create(:magic_link, email:) }
    let(:magic_token) { magic_link.random_token }
    let(:tokens) { magic_link.tokens_from_email }

    context 'when the magic token is still active' do
      context 'when it is linked to one token' do
        let(:token_linked) { create(:token) }

        before { magic_link.update!(token_id: token_linked.id) }

        it 'shows the linked token details' do
          subject

          expect(page).to have_css("input[value='#{token_linked.rehash}']")
        end

        it 'doesnt show the details for other tokens' do
          subject

          expect(page).not_to have_css("input[value='#{tokens.first.rehash}']")
        end
      end

      context 'when it is not linked to one token' do
        it 'has the right number of tokens' do
          expect(tokens.count).to eq(2)
        end

        it 'shows the tokens details' do
          subject

          tokens.each do |token|
            expect(page).to have_css("input[value='#{token.rehash}']")
          end
        end
      end

      it_behaves_like 'display alert', :info

      it 'displays the expiration time of the magic link' do
        subject
        expiration_time = distance_of_time_in_words(Time.zone.now, magic_link.expires_at)

        expect(page).to have_content(expiration_time)
      end

      it 'has a button to copy the tokens hash' do
        subject

        tokens.each do |token|
          expect(page).to have_css("##{dom_id(token, :copy_button)}")
        end
      end

      it 'does not show the tokens renewal button' do
        subject

        tokens.each do |token|
          expect(page).not_to have_button(dom_id(token, :renew))
        end
      end

      it 'does not show the link to the associated authorization requests' do
        subject

        tokens.each do |token|
          expect(page).not_to have_link(href: datapass_authorization_request_url(token.authorization_request))
        end
      end

      it 'does not show the links to the tokens contacts' do
        subject

        tokens.each do |token|
          expect(page).not_to have_link(href: token_contacts_path(token))
        end
      end

      it 'does not allow the magic link creation' do
        subject

        tokens.each do |token|
          expect(page).not_to have_button(dom_id(token, :modal_button))
        end
      end
    end

    context 'when the magic link has expired' do
      before { Timecop.freeze(4.hours.from_now) }

      after { Timecop.return }

      it_behaves_like 'display alert', :error

      it 'redirects to the login page' do
        subject

        expect(page).to have_current_path(login_path)
      end
    end
  end
end
