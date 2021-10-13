require 'rails_helper'

RSpec.describe 'show token from magic link' do
  subject do
    visit token_show_magic_link_path(token: magic_token)
  end

  context 'when the magic link token does not exist' do
    let(:magic_token) { 'wrong token' }

    it 'displays an error' do
      subject

      expect(page).to have_css('.fr-alert--error')
    end

    it 'redirects to the login page' do
      subject

      expect(page).to have_current_path(login_path)
    end
  end

  context 'when the magic link token exists' do
    let!(:jwt) { create(:jwt_api_entreprise, :with_magic_link) }
    let(:magic_token) { jwt.magic_link_token }

    it 'shows the token details' do
      subject

      expect(page).to have_css("input[value='#{jwt.rehash}']")
    end

    context 'when the magic link token has expired' do
      before { Timecop.freeze(Time.zone.now + 4.hours) }

      after { Timecop.return }

      it 'displays an error' do
        subject

        expect(page).to have_css('.fr-alert--error')
      end

      it 'redirects to the login page' do
        subject

        expect(page).to have_current_path(login_path)
      end
    end
  end
end
