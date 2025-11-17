RSpec.describe 'Provider: access', app: :api_entreprise do
  describe '#index' do
    subject(:visit_provider_index) do
      visit provider_path
    end

    context 'without user' do
      it 'redirects to login path' do
        visit_provider_index

        expect(page).to have_current_path(login_path, ignore_query: true)
      end
    end

    context 'with user without provider' do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it 'redirects to root' do
        visit_provider_index

        expect(page).to have_current_path(root_path, ignore_query: true)
      end
    end

    context 'with user with single provider' do
      let(:user) { create(:user, provider_uids: %w[insee]) }

      before do
        login_as(user)
      end

      it 'redirects to provider dashboard' do
        visit_provider_index

        expect(page).to have_current_path(provider_dashboard_path(provider_uid: 'insee'), ignore_query: true)
      end
    end

    context 'with user with multiple providers' do
      let(:user) { create(:user, provider_uids: %w[insee dgfip]) }

      before do
        login_as(user)
      end

      it 'stays on index page' do
        visit_provider_index

        expect(page).to have_current_path(provider_path, ignore_query: true)
      end
    end
  end

  describe '#show' do
    context 'without user' do
      it 'redirects to login path' do
        visit provider_dashboard_path(provider_uid: 'insee')

        expect(page).to have_current_path(login_path, ignore_query: true)
      end
    end

    context 'with user without provider' do
      let(:user) { create(:user) }

      before do
        login_as(user)
      end

      it 'redirects to root' do
        visit provider_dashboard_path(provider_uid: 'insee')

        expect(page).to have_current_path(root_path, ignore_query: true)
      end
    end

    context 'with user with authorized provider' do
      let(:user) { create(:user, provider_uids: %w[insee]) }

      before do
        login_as(user)
      end

      it 'shows the provider dashboard' do
        visit provider_dashboard_path(provider_uid: 'insee')

        expect(page).to have_current_path(provider_dashboard_path(provider_uid: 'insee'), ignore_query: true)
      end
    end

    context 'with user with different provider' do
      let(:user) { create(:user, provider_uids: %w[inpi]) }

      before do
        login_as(user)
      end

      it 'redirects to root' do
        visit provider_dashboard_path(provider_uid: 'insee')

        expect(page).to have_current_path(root_path, ignore_query: true)
      end
    end

    context 'with user with multiple providers including the requested one' do
      let(:user) { create(:user, provider_uids: %w[insee dgfip]) }

      before do
        login_as(user)
      end

      it 'shows the provider dashboard' do
        visit provider_dashboard_path(provider_uid: 'insee')

        expect(page).to have_current_path(provider_dashboard_path(provider_uid: 'insee'), ignore_query: true)
      end
    end
  end
end
