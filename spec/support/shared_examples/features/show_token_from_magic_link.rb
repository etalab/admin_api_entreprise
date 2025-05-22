# frozen_string_literal: true

RSpec.shared_examples 'a show token from magic link feature' do |magic_link_path_method|
  subject do
    visit send(magic_link_path_method, access_token: magic_token)
  end

  let!(:user) { create(:user, email: email) }
  let(:email) { 'any-email@data.gouv.fr' }
  let(:token) { create(:token) }

  # No before block here - specific setups should be in the specs

  context 'when the magic link token does not exist' do
    let(:magic_token) { 'wrong-token' }

    it_behaves_like 'display alert', :error

    it 'redirects to the login page' do
      subject
      expect(page).to have_current_path(login_path)
    end
  end

  context 'when the magic link token exists' do
    let!(:magic_link) { create(:magic_link, email: email, token: token) }
    let(:magic_token) { magic_link.access_token }

    context 'when the magic token is still active' do
      it 'shows the token details' do
        subject
        expect(page).to have_css("input[value='#{token.rehash}']")
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
