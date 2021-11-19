require 'rails_helper'

RSpec.describe 'admin page', type: :feature do
  let(:admin) { create(:user, :admin) }

  let(:valid_siret) { "13002526500013" }

  let(:mardi_24_aout)   { Time.local(2021,8,24,12,0) }

  let(:random_user_uuid)   { "ccfa7701-1ee1-47b5-9af1-4e59dfa453d1" }
  let(:random_token_uuid1) { "5373d24b-bfd0-4327-9762-70f8016f120e" }
  let(:random_token_uuid2) { "77c24c90-01c3-4ef5-91e0-0fcc202ddcb9" }
  let!(:random_user) do
    create(:user,
           context: valid_siret,
           created_at: mardi_24_aout,
           updated_at: mardi_24_aout,
           email: "random@email.com",
           id: random_user_uuid,
           note: "some observations"
          )
  end

  let!(:random_token1) do
    create(:jwt_api_entreprise,
           user: random_user,
           id: random_token_uuid1,
           created_at: mardi_24_aout,
           updated_at: mardi_24_aout,
           exp: Time.local(2022,2,24,12,0),
           subject: "Simplification de démarches",
          )
  end

  let!(:random_token2) { create(:jwt_api_entreprise, user: random_user, id: random_token_uuid2) }
  let!(:archived_token)     { create(:jwt_api_entreprise, archived: true) }
  let!(:not_archived_token) { create(:jwt_api_entreprise, archived: false) }

  let!(:blacklisted_token)      { create(:jwt_api_entreprise, blacklisted: true) }
  let!(:not_blacklisted_token)  { create(:jwt_api_entreprise, blacklisted: false) }

  let!(:confirmed_user)      { create(:user, oauth_api_gouv_id: 12) }
  let!(:unconfirmed_user)    { create(:user, oauth_api_gouv_id: nil) }

  it_behaves_like 'admin_restricted_path', "/admin/users"
  it_behaves_like 'admin_restricted_path', "/admin/users/ccfa7701-1ee1-47b5-9af1-4e59dfa453d1"

  it_behaves_like 'admin_restricted_path', "/admin/tokens"
  it_behaves_like 'admin_restricted_path', "/admin/tokens/5373d24b-bfd0-4327-9762-70f8016f120e"

  describe 'displays users list with generic information' do
    before do
      login_as(admin)
      visit(admin_users_path)
    end

    it 'displays users in a table with one row per user' do
      expect(page.all(".user_summary").size).to eq(User.count)
    end

    it 'email' do
      within('#' << dom_id(random_user)) do
        expect(page).to have_content(random_user.email)
      end
    end

    it 'context' do
      within('#' << dom_id(random_user)) do
        expect(page).to have_content(random_user.context)
      end
    end

    it 'created_at date in a readable fashion' do
      within('#' << dom_id(random_user)) do
        expect(page).to have_content(random_user.created_at.strftime("%d/%m/%Y"))
      end
    end

    it 'confirmed status as Non for unconfirmed user' do
      within('#' << dom_id(unconfirmed_user)) do
        expect(page).to have_content('Non')
      end
    end

    it 'confirmed status as Oui for confirmed user' do
      within('#' << dom_id(confirmed_user)) do
        expect(page).to have_content('Oui')
      end
    end

    it 'links to user details' do
      within('#' << dom_id(random_user)) do
        expect(page).to have_link(random_user.email, href: admin_user_path(random_user))
      end
    end
  end

  describe 'displays user detailed information' do
    before do
      login_as(admin)
      visit(admin_users_path)
      click_link(random_user.email)
    end

    it 'email' do
      expect(page).to have_content(random_user.email)
    end

    it 'note' do
      expect(page).to have_content(random_user.note)
    end

    it 'note edit' do
      within('#' << dom_id(random_user)) do
        click_button 'Editer'
        fill_in 'note', with: 'very note'
        click_button 'Valider'

        expect(page).to have_content('very note')
        expect(random_user.reload.note).to eq('very note')
      end
    end

    it 'context' do
      expect(page).to have_content(random_user.context)
    end
  end

  describe 'display tokens' do
    before do
      login_as(admin)
      visit(admin_tokens_path)
    end

    it 'displays tokens in a table with one row per user' do
      expect(page.all(".token_summary").size).to eq(JwtAPIEntreprise.count)
    end

    it 'created_at' do
      within('#' << dom_id(random_token1)) do
        expect(page).to have_content("24/08/2021")
      end
    end

    it 'subject' do
      within('#' << dom_id(random_token1)) do

        expect(page).to have_content(random_token1.displayed_subject)
      end
    end

    it 'clicking subject redirects to user profile' do
      within('#' << dom_id(random_token1)) do
        click_link(random_token1.displayed_subject)

        expect(page.current_path).to eq(admin_user_path(random_user))
      end
    end

    it 'exp' do
      within('#' << dom_id(random_token1)) do
        expect(page).to have_content("24/02/2022 à 12:00:00")
      end
    end

    it 'blacklisted status as Oui for blacklisted token' do
      within('#' << dom_id(blacklisted_token)) do
        expect(page).to have_content('Oui')
      end
    end

    it 'blacklisted status as Non for not blacklisted token' do
      within('#' << dom_id(not_blacklisted_token)) do
        expect(page).to have_content('Non')
      end
    end

    it 'archived status as Oui for archived token' do
      within('#' << dom_id(archived_token)) do
        expect(page).to have_content('Oui')
      end
    end

    it 'archived status as Non for not archived token' do
      within('#' << dom_id(not_archived_token)) do
        expect(page).to have_content('Non')
      end
    end
  end
end
