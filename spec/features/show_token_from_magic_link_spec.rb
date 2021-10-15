require 'rails_helper'

RSpec.describe 'show token from magic link', type: :feature do
  subject do
    visit token_show_magic_link_path(token: magic_token)
  end

  context 'when the magic link token does not exist' do
    let(:magic_token) { 'wrong token' }

    it_behaves_like :alert_error

    it 'redirects to the login page' do
      subject

      expect(page).to have_current_path(login_path)
    end
  end

  context 'when the magic link token exists' do
    let!(:jwt) { create(:jwt_api_entreprise, :with_magic_link) }
    let(:magic_token) { jwt.magic_link_token }

    context 'when the magic token is still active' do
      it 'shows the token details' do
        subject

        expect(page).to have_css("input[value='#{jwt.rehash}']")
      end

      it_behaves_like :alert_info

      it 'displays the expiration time of the magic link' do
        subject
        expiration_time = distance_of_time_in_words(Time.zone.now, jwt.magic_link_issuance_date + 4.hours)

        expect(page).to have_content(expiration_time)
      end
    end

    context 'when the magic link token has expired' do
      before { Timecop.freeze(Time.zone.now + 4.hours) }

      after { Timecop.return }

      it_behaves_like :alert_error

      it 'redirects to the login page' do
        subject

        expect(page).to have_current_path(login_path)
      end
    end
  end
end
