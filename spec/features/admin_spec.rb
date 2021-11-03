require 'rails_helper'

RSpec.describe 'admin page', type: :feature do
  let(:admin) { create(:user, :admin) }

  let(:valid_siret) { "13002526500013" }

  let(:mardi_24_aout)   { Time.local(2021,8,24,12,0) }

  let(:random_user_uuid) { "ccfa7701-1ee1-47b5-9af1-4e59dfa453d1" }
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



  let!(:confirmed_user)      { create(:user, oauth_api_gouv_id: 12) }
  let!(:unconfirmed_user)    { create(:user, oauth_api_gouv_id: nil) }

  def dom_id(record)
    "#" << [record.class.to_s.underscore, record.id].join('_')
  end

  it_behaves_like 'admin_path', "/admin/users"
  it_behaves_like 'admin_path', "/admin/users/ccfa7701-1ee1-47b5-9af1-4e59dfa453d1"

  describe 'displays users list with generic information' do
    before do
      login_as(admin)
      visit(admin_users_path)
    end

    it 'displays users in a table with one row per user' do
      expect(page.all(".user_summary").size).to eq(User.count)
    end

    it 'email' do
      within(dom_id(random_user)) do
        expect(page).to have_content(random_user.email)
      end
    end

    it 'context' do
      within(dom_id(random_user)) do
        expect(page).to have_content(random_user.context)
      end
    end

    it 'created_at date in a readable fashion' do
      within(dom_id(random_user)) do
        expect(page).to have_content(random_user.created_at.strftime("%d/%m/%Y"))
      end
    end

    it 'confirmed status as Non for unconfirmed user' do
      within(dom_id(unconfirmed_user)) do
        expect(page).to have_content('Non')
      end
    end

    it 'confirmed status as Oui for confirmed user' do
      within(dom_id(confirmed_user)) do
        expect(page).to have_content('Oui')
      end
    end

    it 'links to user details' do
      within(dom_id(random_user)) do
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
      within(dom_id(random_user)) do
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
end
