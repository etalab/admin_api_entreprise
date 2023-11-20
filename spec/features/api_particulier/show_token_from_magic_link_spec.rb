require 'rails_helper'

RSpec.describe 'show token from magic link', app: :api_particulier do
  subject do
    visit api_particulier_token_show_magic_link_path(access_token: magic_token)
  end

  let!(:user) { create(:user, email:) }
  let(:email) { 'any-email@data.gouv.fr' }
  let(:token) { create(:token) }

  before do
    user.authorization_requests.update_all(api: 'particulier')
  end

  context 'when the magic link token does not exist' do
    let(:magic_token) { 'wrong-token' }

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
      it 'shows the token details' do
        subject

        expect(page).to have_css("input[value='#{token.rehash}']")
      end

      it 'has a button to copy the token hashes' do
        subject

        expect(page).to have_css("##{dom_id(token, :copy_token_button)}")
      end
    end

    context 'when the magic link token has expired' do
      before { Timecop.freeze(24.hours.from_now) }

      after { Timecop.return }

      it_behaves_like 'display alert', :error

      it 'redirects to the login page' do
        subject

        expect(page).to have_current_path(login_path)
      end
    end
  end
end
