require 'rails_helper'

RSpec.describe 'User can download attestations', type: :feature do
  describe 'side menu' do
    subject(:visit_profile) { visit user_profile_path }

    before do
      login_as(user)
      visit_profile
    end

    context 'when user has no attestations role' do
      let(:user) { create(:user) }

      it 'hides menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).not_to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))
        end
      end
    end

    context 'when user has attestations role' do
      let(:user) { create :user, :with_jwt_specific_roles, specific_roles: ['attestations_fiscales'] }

      it 'shows menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))
        end
      end
    end
  end
end
