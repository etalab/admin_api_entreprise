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
    subject(:visit_attestations) { visit profile_attestations_path }

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
        expect(page.all('select#token option').map(&:text)).to eq([
          '',
          'JWT with roles: ["attestations_fiscales"]',
          'JWT with no roles'
        ])
      end

      it 'tell user to select a token' do
        expect(page).to have_content('Selectionnez un token pour voir les droits')
      end

      context 'when user select token with roles', js: true do
        before { select('JWT with roles: ["attestations_fiscales"]', from: 'token') }

        it 'shows roles' do
          expect(page).to have_content("Attestations téléchargeables avec ce token:\nAttestations fiscales")
        end
      end

      context 'when user select token with no roles', js: true do
        before { select('JWT with no roles', from: 'token') }

        it 'shows no roles' do
          expect(page).to have_content('Aucune attestation disponible avec ce token')
        end
      end

      context 'when user comes back to empty selection', js: true do
        before do
          select('JWT with roles: ["attestations_fiscales"]', from: 'token')
          select('', from: 'token')
        end

        it 'ask to select a token' do
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

  describe 'search' do
    subject(:search) do
      login_as(user)
      visit profile_attestations_path
      select(token, from: 'token')
      fill_in('search_siret', with: siret)
      click_button('search')
    end

    let(:user) { create :user, :with_jwt_specific_roles, specific_roles: ['attestations_fiscales'] }
    let(:token) { 'JWT with no roles' }

    before do
      allow_any_instance_of(JwtAPIEntreprise).to receive(:rehash).and_return(apientreprise_test_token)
      search
      FactoryBot.rewind_sequences
    end

    context 'when user search a valid siret', vcr: { cassette_name: 'features/user_attestations/valid_siret' } do
      let(:siret) { siret_valid }

      it 'shows company information' do
        expect(page).to have_content('JK AC')
      end

      context 'when selected token have no attestation roles' do
        it 'doesnt show attestations download buttons' do
          expect(page).not_to have_button('Attestation sociale')
          expect(page).not_to have_button('Attestation Fiscale')
        end
      end

      context 'when selected token have one attestation role' do
        let(:token) { 'JWT with roles: ["attestations_fiscales"]' }

        it 'shows button to download this attestation' do
          expect(page).not_to have_button('Attestation sociale')
          expect(page).to have_button('Attestation Fiscale')
        end
      end

      context 'when selected token have two attestation roles' do
        let(:user) do
          create :user,
            :with_jwt_specific_roles,
            specific_roles: %w[attestions_sociales attestations_fiscales]
        end

        let(:token) { 'JWT with roles: ["attestations_sociales", "attestations_fiscales"]' }

        it 'shows both button to download attestations' do
          expect(page).to have_button('Attestation sociale')
          expect(page).to have_button('Attestation Fiscale')
        end
      end
    end

    context 'when user search an invalid siret', vcr: { cassette_name: 'features/user_attestations/invalid_siret' } do
      let(:siret) { siret_invalid }

      it 'fails with invalid message' do
        expect(page).to have_content('Erreur: Siret invalide.')
      end
    end

    context 'when user search a siret not found', vcr: { cassette_name: 'features/user_attestations/siret_not_found' } do
      let(:siret) { siret_not_found }

      it 'fails with not found message' do
        expect(page).to have_content('Erreur: Siret non trouvé.')
      end
    end
  end
end
