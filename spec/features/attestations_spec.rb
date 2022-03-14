require 'rails_helper'

RSpec.describe 'User can download attestations', type: :feature do
  include_context 'with siade payloads'

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

      context 'when user select token with roles', js: true do
        before { select('JWT with roles: ["attestations_fiscales"]', from: 'token') }

        it 'shows roles' do
          expect(page).to have_content("Attestations disponibles pour ce token :\nAttestations fiscales")
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

  describe 'search', js: true do
    subject(:search) do
      login_as(user)
      visit profile_attestations_path
      select(token, from: 'token')
      fill_in('search_siret', with: siret)
      click_button('search')
    end

    let(:user) { create(:user, :with_jwt_specific_roles, specific_roles: ['attestations_fiscales']) }
    let(:siret) { siret_valid }
    let(:token) { 'JWT with no roles' }

    context 'when user search a valid siret', vcr: { cassette_name: 'features/attestations/valid_siret' } do
      let(:token) { 'JWT with roles: ["attestations_fiscales"]' }

      before do
        allow_any_instance_of(Siade).to receive(:entreprises).and_return(payload_entreprise)
        allow_any_instance_of(Siade).to receive(:attestations_fiscales).and_return(payload_attestation_fiscale)
        allow_any_instance_of(Siade).to receive(:attestations_sociales).and_return(payload_attestation_sociale)
        search
      end

      it 'shows company name' do
        expect(page).to have_content('dummy name')
      end

      context 'when selected token have no attestation roles' do
        let(:token) { 'JWT with no roles' }

        it 'doesnt show attestations download links' do
          expect(page).not_to have_link('Attestation sociale', href: 'dummy url sociale')
          expect(page).not_to have_link('Attestation fiscale')
        end
      end

      context 'when selected token have one attestation role' do
        let(:token) { 'JWT with roles: ["attestations_fiscales"]' }

        it 'shows link to download this attestation' do
          expect(page).not_to have_link('Attestation sociale')
          expect(page).to have_link('Attestation fiscale', href: 'dummy url fiscale')
        end
      end

      context 'when selected token have two attestation roles' do
        let(:user) do
          create :user,
            :with_jwt_specific_roles,
            specific_roles: %w[attestations_sociales attestations_fiscales]
        end

        let(:token) { 'JWT with roles: ["attestations_sociales", "attestations_fiscales"]' }

        it 'shows both links to download attestations' do
          expect(page).to have_link('Attestation sociale', href: 'dummy url sociale')
          expect(page).to have_link('Attestation fiscale', href: 'dummy url fiscale')
        end
      end
    end

    context 'when user search an invalid siret' do
      before do
        allow_any_instance_of(Siade).to receive(:entreprises).and_raise('422 Unprocessable Entity')
        search
      end

      it 'fails with invalid message' do
        expect(page).to have_content('422 Unprocessable Entity')
      end
    end

    context 'when user search a siret not found' do
      before do
        allow_any_instance_of(Siade).to receive(:entreprises).and_raise('404 Not Found')
        search
      end

      it 'fails with not found message' do
        expect(page).to have_content('404 Not Found')
      end
    end

    context 'when user is unauthorized' do
      before do
        allow_any_instance_of(Siade).to receive(:entreprises).and_raise('401 Unauthorized')
        search
      end

      it 'fails with invalid message' do
        expect(page).to have_content('401 Unauthorized')
      end
    end
  end
end
