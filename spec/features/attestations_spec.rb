require 'rails_helper'

RSpec.describe 'User attestations through tokens', type: :feature do
  include_context 'with siade payloads'

  describe 'token selection menu' do
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
      let(:user) { create(:user, :with_jwt, roles: %w[attestations_sociales attestations_fiscales]) }
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
      fill_in('search_siren', with: siren)
      click_button('search')
    end

    before { allow(Siade).to receive(:new).and_return(siade_double) }

    let(:siade_double) { instance_double(Siade) }
    let(:user) { create(:user, :with_jwt, roles: ['attestations_fiscales']) }
    let(:siren) { siren_valid }
    let(:token) { 'JWT with no roles' }

    context 'when user search a valid siren' do
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
          expect(page).not_to have_link('attestation-sociale-download')
          expect(page).not_to have_link('attestation-fiscale-download')
        end
      end

      context 'when selected token have one attestation role' do
        let(:token) { 'JWT with roles: ["attestations_fiscales"]' }

        it 'shows link to download this attestation only, not the other' do
          expect(page).not_to have_link('attestation-sociale-download')
          expect(page).to have_link('attestation-fiscale-download',
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
        end
      end

      context 'when selected token have two attestation roles' do
        let(:user) do
          create :user, :with_jwt, roles: %w[attestations_sociales attestations_fiscales]
        end

        let(:token) { 'JWT with roles: ["attestations_sociales", "attestations_fiscales"]' }

        it 'shows both links to download attestations' do
          expect(page).to have_link('attestation-sociale-download',
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_sociale.pdf')
          expect(page).to have_link('attestation-fiscale-download',
            href: 'http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
        end
      end
    end

    context 'when user search an invalid siren' do
      before do
        allow(siade_double).to receive(:entreprises).and_raise(SiadeClientError.new(422, '422 Unprocessable Entity'))
        search
      end

      it 'fails with invalid message' do
        expect(page).to have_css('#error-422')
      end
    end

    context 'when user search a siren not found' do
      before do
        allow(siade_double).to receive(:entreprises).and_raise(SiadeClientError.new(404, '404 Not Found'))
        search
      end

      it 'fails with not found message' do
        expect(page).to have_css('#error-404')
      end
    end

    context 'when user choose a token which is unauthorized' do
      before do
        allow(siade_double).to receive(:entreprises).and_raise(SiadeClientError.new(401, '401 Unauthorized'))
        search
      end

      it 'fails with invalid message' do
        expect(page).to have_css('#error-401')
      end
    end
  end
end
