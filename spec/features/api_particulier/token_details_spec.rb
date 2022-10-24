RSpec.describe 'API Particulier: token details', app: :api_particulier do
  subject(:go_to_profile) { visit api_particulier_user_profile_path }

  let(:user) { create(:user) }
  let(:scopes) { [create(:scope, api: 'particulier', name: 'Scope 1')] }

  let!(:token) { create(:token, user:, scopes:) }

  before do
    login_as(user)

    go_to_profile
  end

  it 'displays token data' do
    expect(page).to have_content(token.intitule)
    expect(page).to have_content(friendly_format_from_timestamp(token.iat))
    expect(page).to have_content(friendly_format_from_timestamp(token.exp))
    expect(page).to have_content('Scope 1')
  end

  it 'has a button to copy active tokens hash to clipboard' do
    expect(page).to have_css("##{dom_id(token, :copy_button)}")
  end

  it 'has a link to authorization request' do
    expect(page).to have_link(href: datapass_authorization_request_url(token.authorization_request))
  end
end
