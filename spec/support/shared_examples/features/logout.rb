# frozen_string_literal: true

RSpec.shared_examples 'a logout feature' do |controller_class, profile_path_method|
  subject do
    visit send(profile_path_method)
    click_link 'logout_button'
  end

  before do
    login_as(create(:user))
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(controller_class).to receive(:oauth_logout_url).and_return(after_logout_path)
    # rubocop:enable RSpec/AnyInstance
  end

  it 'clears the session' do
    subject
    session_data = page.get_rack_session

    expect(session_data).not_to have_key('current_user_id')
  end

  it 'redirects to the main page with an alert' do
    subject

    expect(page).to have_current_path(root_path)
    expect(page).to have_css('#alerts')
  end
end
