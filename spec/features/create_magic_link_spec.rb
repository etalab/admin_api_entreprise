require 'rails_helper'

RSpec.describe 'create a magic link', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  let(:token) { user.jwt_api_entreprise.take }

  before { login_as(user) }

  subject do
    visit user_tokens_path
    click_button dom_id(token, :modal_button)
    within("#" + dom_id(token, :magic_link)) do
      fill_in 'email', with: email
      click_button
    end
  end

  context 'when the email address is valid' do
    let(:email) { 'valid@email.com' }

    it 'notifies of success' do
      subject

      expect(page).to have_css('.fr-alert--success')
    end

    it 'sends the email magic link' do
      expect { subject }
        .to have_enqueued_mail(JwtAPIEntrepriseMailer, :magic_link)
        .with(args: [email, token])
    end

    it 'redirects to the user token index page' do
      subject

      expect(page).to have_current_path(user_tokens_path)
    end

    describe 'the token record' do
      it 'saves a magic token' do
        subject

        expect(token.reload.magic_link_token).to match(/\A[0-9a-f]{20}\z/)
      end

      it 'saves the issuance date of the magic token' do
        creation_time = Time.zone.now
        Timecop.freeze(creation_time) do
          subject

          expect(token.reload.magic_link_issuance_date.to_i).to eq(creation_time.to_i)
        end
      end
    end
  end

  context 'when the email address is invalid' do
    let(:email) { 'not an email' }

    it 'displays an error' do
      subject

      expect(page).to have_css('.fr-alert--error')
    end

    it 'does not send the magic link email' do
      expect { subject }
        .not_to have_enqueued_mail(JwtAPIEntrepriseMailer, :magic_link)
    end

    it 'redirects to the user token index page' do
      subject

      expect(page).to have_current_path(user_tokens_path)
    end
  end
end
