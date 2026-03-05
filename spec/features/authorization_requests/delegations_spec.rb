RSpec.describe 'Authorization requests: delegations', app: :api_entreprise do
  let(:user) { create(:user) }
  let(:authorization_request) { create(:authorization_request, :validated, api: 'entreprise') }
  let!(:demandeur_role) { create(:user_authorization_request_role, user:, authorization_request:, role: 'demandeur') }
  let!(:token) { create(:token, authorization_request:) }

  before do
    login_as(user)
  end

  context 'when delegable editors exist' do
    let!(:delegable_editor) { create(:editor, :delegable, name: 'UMAD Corp') }

    it 'displays the delegations section' do
      visit authorization_request_path(authorization_request)

      expect(page).to have_css('#habilitation_delegations')
    end

    it 'allows adding a delegation' do
      visit authorization_request_path(authorization_request)

      select 'UMAD Corp', from: 'editor_id'
      click_on 'Ajouter'

      expect(page).to have_css('.fr-alert--success')
      expect(page).to have_content('UMAD Corp')
      expect(page).to have_css('.fr-badge--green-emeraude', text: 'Actif')
    end

    context 'with an active delegation' do
      let!(:delegation) { create(:editor_delegation, editor: delegable_editor, authorization_request:) }

      it 'displays the active delegation' do
        visit authorization_request_path(authorization_request)

        expect(page).to have_content('UMAD Corp')
        expect(page).to have_css('.fr-badge--green-emeraude', text: 'Actif')
      end

      it 'allows revoking a delegation' do
        visit authorization_request_path(authorization_request)

        click_on 'Révoquer'

        expect(page).to have_css('.fr-alert--success')
        expect(delegation.reload.revoked_at).to be_present
      end

      it 'does not show the editor in the add dropdown' do
        visit authorization_request_path(authorization_request)

        expect(page).to have_css('#habilitation_delegations')
        expect(page).to have_no_select('editor_id', with_options: ['UMAD Corp'])
      end
    end
  end

  context 'when no delegable editors exist' do
    it 'does not display the delegations section' do
      visit authorization_request_path(authorization_request)

      expect(page).to have_css('#habilitation_contacts_infos')
      expect(page).to have_no_css('#habilitation_delegations')
    end
  end
end
