RSpec.describe 'API Particulier: profile spec', app: :api_particulier do
  subject(:go_to_profile) { visit api_particulier_user_profile_path }

  let(:user) { create(:user, :with_token) }

  context 'when user is not authenticated' do
    it 'redirects to the login' do
      go_to_profile

      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end
  end
end
