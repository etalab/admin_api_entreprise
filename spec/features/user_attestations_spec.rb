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

  describe 'select menu' do
    subject(:visit_attestations) { visit user_attestations_path }

    before do
      login_as(user)
      visit_attestations
      FactoryBot.rewind_sequences
    end

    context 'when user has tokens with attestation roles' do
      let(:user) { create :user, :with_jwt_specific_roles, specific_roles: ['attestations_fiscales'] }

      it 'has a select list' do
        expect(page).to have_select('token')
      end

      it 'select list has 3 options' do
        expect(page.all('select#token option').map(&:text)).to eq(['', 'Intitule 1', 'Intitule 2', 'Intitule 3'])
      end

      it 'tell user to select a token' do
        expect(page).to have_content('Selectionnez un token pour voir les droits')
      end

      context 'when user select token with roles', js: true do
        it 'shows roles' do
          select('Intitule 1', from: 'token')

          expect(page).to have_content("Attestations téléchargeables avec ce token:\nAttestations fiscales")
        end
      end

      context 'when user select token with no roles', js: true do
        it 'shows no roles' do
          select('Intitule 2', from: 'token')

          expect(page).to have_content('Aucune attestation disponible avec ce token')
        end
      end

      context 'when user comes back to empty selection', js: true do
        it 'ask to select a token' do
          select('Intitule 1', from: 'token')
          select('', from: 'token')

          expect(page).to have_content('Veuillez sélectionner un token dans la liste.')
        end
      end
    end

    context 'when user has no token with attestation roles' do
      let(:user) { create(:user) }

      it 'does not have a select list' do
        expect(page).not_to have_select('token')
      end
    end
  end
end
