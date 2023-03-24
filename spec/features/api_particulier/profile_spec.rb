RSpec.describe 'API Particulier: profile spec', app: :api_particulier do
  subject(:go_to_profile) { visit api_particulier_user_profile_path }

  let(:user) { create(:user) }

  context 'when user is not authenticated' do
    it 'redirects to the login' do
      go_to_profile

      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end
  end

  context 'when user is authenticated' do
    before do
      login_as(user)
    end

    context 'when user has no token' do
      it 'displays no token disclaimer' do
        go_to_profile

        expect(page).to have_css('#no_token_disclaimer')
      end
    end

    context 'when user has at least one token' do
      let!(:token) { create(:token, user:, scopes:) }

      context 'when this token is for API Entreprise' do
        let(:scopes) { %w[x1x] }

        it 'displays no token disclaimer' do
          go_to_profile

          expect(page).to have_css('#no_token_disclaimer')
        end
      end

      context 'when this token is for API Particulier' do
        let!(:token) { create(:token, :with_api_particulier, user:, scopes:) }
        let(:scopes) { %w[x1x] }

        it 'display this token' do
          go_to_profile
          expect(page).to have_css("##{dom_id(token)}")
        end
      end
    end
  end
end
