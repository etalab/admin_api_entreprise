RSpec.describe 'Admin: tokens', app: :api_entreprise do
  let(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }
  let!(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique, demandeur: user, api: 'entreprise') }
  let!(:token) { create(:token, authorization_request:) }

  before do
    login_as(admin)
  end

  describe 'viewing tokens for a user' do
    subject(:view_tokens) do
      visit admin_users_path
      click_on dom_id(user, :tokens)
    end

    it 'displays all tokens for the user' do
      view_tokens

      expect(page).to have_current_path(admin_user_tokens_path(user))
      expect(page).to have_content(user.email)
      expect(page).to have_css('.token', count: 1)
      expect(page).to have_content(authorization_request.intitule)
    end

    it 'displays obfuscated token rehash' do
      view_tokens

      rehash = token.rehash
      obfuscated = "...#{rehash[-30..]}"
      expect(page).to have_content(obfuscated)
    end

    it 'shows active status for active tokens' do
      view_tokens

      within("##{dom_id(token)}") do
        expect(page).to have_content('Actif')
      end
    end

    it 'shows ban link for active tokens' do
      view_tokens

      within("##{dom_id(token)}") do
        expect(page).to have_link('Bannir')
      end
    end

    context 'when token is inactive' do
      let!(:token) { create(:token, :blacklisted, authorization_request:) }

      it 'shows inactive status' do
        view_tokens

        within("##{dom_id(token)}") do
          expect(page).to have_content('Inactif')
          expect(page).to have_no_link('Bannir')
        end
      end
    end
  end

  describe 'banning a token', :js do
    subject(:ban_token) do
      visit admin_user_tokens_path(user)
      click_on dom_id(token, :ban)
      within('#main-modal-content') do
        click_button 'Bannir le token'
      end
    end

    it 'bans the token and creates a new one', :aggregate_failures do
      expect { ban_token }.to change { token.reload.blacklisted_at }.from(nil)

      expect(page).to have_css('.fr-alert.fr-alert--success')
      expect(page).to have_current_path(admin_user_tokens_path(user))
    end

    it 'sends email to demandeur and contact technique' do
      expect { ban_token }.to have_enqueued_job(ActionMailer::MailDeliveryJob).at_least(2).times
    end

    it 'allows setting a custom blacklist date' do
      visit admin_user_tokens_path(user)
      click_on dom_id(token, :ban)

      custom_date = 7.days.from_now
      within('#main-modal-content') do
        fill_in 'blacklisted_at', with: custom_date.strftime('%Y-%m-%dT%H:%M')
        click_button 'Bannir le token'
      end

      expect(token.reload.blacklisted_at).to be_within(1.minute).of(custom_date)
    end

    it 'does not generate new token when unchecked' do
      visit admin_user_tokens_path(user)
      click_on dom_id(token, :ban)

      within('#main-modal-content') do
        checkbox = find_by_id('generate_new_token', visible: :all)
        checkbox.execute_script('this.click()')
        click_button 'Bannir le token'
      end

      expect(page).to have_css('.fr-alert.fr-alert--success')
      expect(user.tokens.count).to eq(1)
    end
  end
end
