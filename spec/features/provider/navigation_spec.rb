require 'rails_helper'

RSpec.describe 'Provider space navigation', app: :api_entreprise do
  before do
    login_as(user)
  end

  describe 'provider path' do
    context 'with no provider associations' do
      let(:user) { create(:user) }

      it 'redirects to root' do
        visit provider_path

        expect(page).to have_current_path(root_path)
      end
    end

    context 'with a single provider' do
      let(:user) { create(:user, provider_uids: %w[insee]) }

      it 'redirects to provider dashboard' do
        visit provider_path

        expect(page).to have_current_path(provider_dashboard_path('insee'))
      end
    end

    context 'with multiple providers' do
      let(:user) { create(:user, provider_uids: %w[insee dgfip]) }

      it 'shows list of providers' do
        visit provider_path

        expect(page).to have_content('INSEE')
        expect(page).to have_content('DGFIP')

        expect(page).to have_link(href: provider_dashboard_path(provider_uid: 'insee'))
        expect(page).to have_link(href: provider_dashboard_path(provider_uid: 'dgfip'))
      end
    end
  end
end
