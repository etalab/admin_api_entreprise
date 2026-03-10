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

  describe 'creating a token', :js do
    before do
      authorization_request.update!(status: 'validated', validated_at: Time.zone.now)
    end

    it 'creates a new token for the selected authorization request' do
      visit admin_user_tokens_path(user)
      click_on 'create-token'

      within('#main-modal-content') do
        select "#{authorization_request.intitule} (DataPass ##{authorization_request.external_id})", from: 'authorization_request_id'
        click_button 'Créer le jeton'
      end

      expect(page).to have_css('.fr-alert.fr-alert--success')
      expect(page).to have_current_path(admin_user_tokens_path(user))
      expect(user.tokens.count).to eq(2)
    end

    it 'creates a token with the authorization request scopes' do
      authorization_request.update!(scopes: %w[unites_legales associations])

      visit admin_user_tokens_path(user)
      click_on 'create-token'

      within('#main-modal-content') do
        click_button 'Créer le jeton'
      end

      expect(page).to have_css('.fr-alert.fr-alert--success')
      new_token = user.tokens.order(:created_at).last
      expect(new_token.scopes).to eq(%w[unites_legales associations])
    end

    it 'creates a token with a custom expiration date' do
      custom_date = 6.months.from_now.to_date

      visit admin_user_tokens_path(user)
      click_on 'create-token'

      within('#main-modal-content') do
        fill_in 'exp', with: custom_date.strftime('%Y-%m-%d')
        click_button 'Créer le jeton'
      end

      expect(page).to have_css('.fr-alert.fr-alert--success')
      new_token = user.tokens.order(:created_at).last
      expect(Time.zone.at(new_token.exp).to_date).to eq(custom_date)
    end

    it 'shows the create token button' do
      visit admin_user_tokens_path(user)

      expect(page).to have_link('Créer un nouveau jeton')
    end

    it 'displays the scopes of the selected authorization request' do
      authorization_request.update!(scopes: %w[unites_legales associations])

      visit admin_user_tokens_path(user)
      click_on 'create-token'

      within('#main-modal-content') do
        expect(page).to have_content('unites_legales, associations')
      end
    end

    it 'rejects a past expiration date' do
      past_date = 1.day.ago.to_date.strftime('%Y-%m-%d')

      visit admin_user_tokens_path(user)
      click_on 'create-token'

      within('#main-modal-content') do
        find_by_id('exp').execute_script("this.removeAttribute('min'); this.value = '#{past_date}'")
        click_button 'Créer le jeton'
      end

      expect(page).to have_css('.fr-alert.fr-alert--error')
      expect(user.tokens.count).to eq(1)
    end

    it 'allows dismissing the success alert' do
      visit admin_user_tokens_path(user)
      click_on 'create-token'

      within('#main-modal-content') do
        click_button 'Créer le jeton'
      end

      expect(page).to have_css('.fr-alert.fr-alert--success')
      find('.fr-alert.fr-alert--success .fr-btn--close').click
      expect(page).to have_no_css('.fr-alert.fr-alert--success')
    end

    it 'only lists validated authorization requests in the select' do
      revoked_ar = create(:authorization_request, :with_demandeur, demandeur: user, api: 'entreprise', status: 'revoked', intitule: 'Revoked AR')
      archived_ar = create(:authorization_request, :with_demandeur, demandeur: user, api: 'entreprise', status: 'archived', intitule: 'Archived AR')
      draft_ar = create(:authorization_request, :with_demandeur, demandeur: user, api: 'entreprise', status: 'draft', intitule: 'Draft AR')

      visit admin_user_tokens_path(user)
      click_on 'create-token'

      within('#main-modal-content') do
        expect(page).to have_select('authorization_request_id', with_options: [
          "#{authorization_request.intitule} (DataPass ##{authorization_request.external_id})"
        ])
        expect(page).to have_no_content(revoked_ar.intitule)
        expect(page).to have_no_content(archived_ar.intitule)
        expect(page).to have_no_content(draft_ar.intitule)
      end
    end
  end
end
