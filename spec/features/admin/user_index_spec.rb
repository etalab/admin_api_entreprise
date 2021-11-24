require 'rails_helper'

RSpec.describe 'admin user index', type: :feature do
  let(:admin) { create(:user, :admin) }
  let!(:users) { create_list(:user, 3) }
  let!(:confirmed_user) { create(:user, :confirmed) }
  let!(:unconfirmed_user) { create(:user, :unconfirmed) }
  let(:random_user) { users.shuffle.first }

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
