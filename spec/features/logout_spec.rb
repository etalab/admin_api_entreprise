require 'rails_helper'

RSpec.describe 'log out', type: :feature do
  before { login_as(create(:user)) }

  subject do
    visit user_profile_path
    click_link 'logout_button'
  end

  it 'clears the session' do
    subject
    session_data = page.get_rack_session

    expect(session_data).not_to have_key('current_user_id')
  end

  it 'redirects to the login page' do
    subject

    expect(page).to have_current_path(login_path)
  end
end
