RSpec.describe 'Provider: access', app: :api_entreprise do
  subject(:visit_provider) do
    visit provider_path
  end

  context 'without user' do
    it 'redirects to login path' do
      visit_provider

      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'with user' do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end

    it 'redirects to root' do
      visit_provider

      expect(page).to have_current_path(root_path, ignore_query: true)
    end
  end

  context 'with provider' do
    let(:user) { create(:user, provider_uids: %w[insee]) }

    before do
      login_as(user)
    end

    it 'does not redirect to root' do
      visit_provider

      expect(page).to have_current_path(provider_dashboard_path(provider_uid: 'insee'), ignore_query: true)
    end
  end
end
