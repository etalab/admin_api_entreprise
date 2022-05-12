require 'rails_helper'

RSpec.describe 'Navigation side menu', type: :feature do
  subject(:visit_profile) { visit user_profile_path }

  before do
    login_as(user)
    visit_profile
  end

  describe 'attestation tab' do
    context 'when user has no attestations scope' do
      let(:user) { create(:user) }

      it 'hides menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).not_to have_link('attestations-download')
        end
      end
    end

    context 'when user has attestations scope' do
      let(:user) { create :user, :with_jwt, scopes: ['attestations_fiscales'] }

      it 'shows menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).to have_link('attestations-download', href: attestations_path)
        end
      end
    end
  end
end
