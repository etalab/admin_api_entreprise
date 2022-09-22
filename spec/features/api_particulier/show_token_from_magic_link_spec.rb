RSpec.describe 'show token from magic link', type: :feature, app: :api_particulier do
  subject do
    visit api_particulier_token_show_magic_link_path(token: magic_token)
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
    let!(:token) { create(:token, :with_magic_link) }
    let(:magic_token) { token.magic_link_token }

    context 'when the magic token is still active' do
      it 'shows the token details' do
        subject

        expect(page).to have_css("input[value='#{token.rehash}']")
      end

      it 'has a button to copy the token hash' do
        subject

        expect(page).to have_css("##{dom_id(token, :copy_button)}")
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
