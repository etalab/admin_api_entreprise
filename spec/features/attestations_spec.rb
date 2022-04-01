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
    subject(:visit_attestations) { visit attestations_path }

    let(:user) { create :user }

    before do
      login_as(user)
      visit_attestations
    end

    context 'when user has no token with attestation roles' do
      it 'redirect to profile' do
        expect(page).to have_current_path('/profile')
      end
    end

    context 'when user has tokens with attestation roles' do
      let(:user) { create(:user, :with_jwt_specific_roles, specific_roles: %w[attestations_sociales attestations_fiscales]) }
      let(:id_selected_jwt) { find('select#token').value }
      let(:roles_selected_jwt) { JwtAPIEntreprise.find(id_selected_jwt).roles }

      it 'has a select list' do
        expect(page).to have_select('token')
      end

      it 'automatically select token with the most permissions' do
        expect(roles_selected_jwt.count).to eq(2)
      end

      it 'select list has 2 options' do
        expect(page.all('select#token option').count).to eq(2)
      end
    end
  end

  describe 'search', js: true do
    subject(:search) do
      login_as(user)
      visit attestations_path
      select(token, from: 'token')
      fill_in('search_siret', with: siret)
      click_button('search')
    end

    before { allow(Siade).to receive(:new).and_return(siade_double) }

    let(:siade_double) { class_double('SiadeService') }
    let(:user) { create(:user, :with_jwt_specific_roles, specific_roles: ['attestations_fiscales']) }
    let(:siret) { siret_valid }
    let(:token) { 'JWT with no roles' }

    context 'when user search a valid siret' do
      let(:token) { 'JWT with roles: ["attestations_fiscales"]' }

      before do
        allow(siade_double).to receive(:entreprises).and_return(payload_entreprise)
        allow(siade_double).to receive(:attestations_fiscales).and_return(payload_attestation_fiscale)
        allow(siade_double).to receive(:attestations_sociales).and_return(payload_attestation_sociale)
        search
      end

      it 'shows company name' do
        expect(page).to have_content('dummy name')
      end

      context 'when selected token have no attestation roles' do
        let(:token) { 'JWT with no roles' }

        it 'doesnt show attestations download links' do
          expect(page).not_to have_link(I18n.t('.attestations.search.attestation_sociale'),
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_sociale.pdf')
          expect(page).not_to have_link(I18n.t('.attestations.search.attestation_fiscale'))
        end
      end

      context 'when selected token have one attestation role' do
        let(:token) { 'JWT with roles: ["attestations_fiscales"]' }

        it 'shows link to download this attestation only, not the other' do
          expect(page).not_to have_link(I18n.t('.attestations.search.attestation_sociale'))
          expect(page).to have_link(I18n.t('.attestations.search.attestation_fiscale'),
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
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
          expect(page).to have_link(I18n.t('.attestations.search.attestation_sociale'),
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_sociale.pdf')
          expect(page).to have_link(I18n.t('.attestations.search.attestation_fiscale'),
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
        end
      end
    end

    context 'when user search an invalid siret' do
      before do
        allow(siade_double).to receive(:entreprises).and_raise(SiadeClientError.new(msg: '422 Unprocessable Entity'))
        search
      end

      it 'fails with invalid message' do
        expect(page).to have_content('422 Unprocessable Entity')
      end
    end

    context 'when user search a siret not found' do
      before do
        allow(siade_double).to receive(:entreprises).and_raise(SiadeClientError.new(msg: '404 Not Found'))
        search
      end

      it 'fails with not found message' do
        expect(page).to have_content('404 Not Found')
      end
    end

    context 'when user is unauthorized' do
      before do
        allow(siade_double).to receive(:entreprises).and_raise(SiadeClientError.new(msg: '401 Unauthorized'))
        search
      end

      it 'fails with invalid message' do
        expect(page).to have_content('401 Unauthorized')
      end
    end
  end
end
