RSpec.shared_examples 'client user unauthorized' do |req_verb, action, req_params = {}|
  include_context 'user request'
  before { self.send(req_verb, action, params: req_params) }

  it 'returns 403' do
    expect(response.code).to eq '403'
  end

  it 'returns "Forbidden" message' do
    body = JSON.parse(response.body, symbolize_names: true)
    expect(body[:errors]).to eq 'Forbidden'
  end
end

RSpec.shared_examples 'admin_restricted_path' do |admin_restricted_path|
  it 'redirects disconnected user to login page' do
    visit admin_restricted_path

    expect(page.current_path).to eq(login_path)
  end

  it 'redirects logged in regular users to their profile' do
    user = create(:user)
    login_as(user)

    visit admin_restricted_path

    expect(page.current_path).to eq(user_profile_path)
  end

  it 'directs logged in admins to admin_restricted path (identical or redirect) ' do
    admin = create(:user, :admin)
    login_as(admin)

    visit admin_restricted_path

    expect(page.current_path).to eq(admin_restricted_path).or(match(/\A\/admin\//))
  end
end
