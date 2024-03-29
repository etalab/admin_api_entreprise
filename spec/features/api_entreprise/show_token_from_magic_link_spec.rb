require 'rails_helper'

RSpec.describe 'show token from magic link', app: :api_entreprise do
  subject do
    visit token_show_magic_link_path(access_token: magic_token)
  end

  let!(:user) { create(:user, :with_token, email:) }
  let!(:token) { create(:token) }
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
    let!(:magic_link) { create(:magic_link, email:, token:) }
    let(:magic_token) { magic_link.access_token }

    context 'when the magic token is still active' do
      context 'when it is linked to one token' do
        let(:token_linked) { create(:token) }

        before { magic_link.update!(token_id: token_linked.id) }

        it 'shows only the linked token details' do
          subject

          expect(page).to have_css("##{dom_id(token_linked)}")
        end
      end

      context 'when it is not linked to one token' do
        it 'shows the token details' do
          subject

          expect(page).to have_css("input[value='#{token.rehash}']")
        end
      end

      it_behaves_like 'display alert', :info

      it 'displays the expiration time of the magic link' do
        subject
        expiration_time = distance_of_time_in_words(Time.zone.now, magic_link.expires_at)

        expect(page).to have_content(expiration_time)
      end

      it 'has a button to copy the token hash' do
        subject

        expect(page).to have_css("##{dom_id(token, :copy_token_button)}")
      end
    end

    context 'when the magic link has expired' do
      before { Timecop.freeze((MagicLink::DEFAULT_EXPIRATION_DELAY + 1.hour).from_now) }

      after { Timecop.return }

      it_behaves_like 'display alert', :error

      it 'redirects to the login page' do
        subject

        expect(page).to have_current_path(login_path)
      end
    end
  end
end
