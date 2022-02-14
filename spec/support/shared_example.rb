RSpec.shared_examples 'admin_restricted_path' do |admin_restricted_path|
  it 'redirects disconnected user to login page' do
    visit admin_restricted_path

    expect(page).to have_current_path(login_path, ignore_query: true)
  end

  it 'redirects logged in regular users to their profile' do
    user = create(:user)
    login_as(user)

    visit admin_restricted_path

    expect(page).to have_current_path(user_profile_path, ignore_query: true)
  end

  it 'directs logged in admins to admin_restricted path (identical or redirect)' do
    admin = create(:user, :admin)
    login_as(admin)

    visit admin_restricted_path

    expect(page.current_path).to eq(admin_restricted_path).or(match(%r{\A/admin/}))
  end
end
