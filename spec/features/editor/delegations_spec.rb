RSpec.describe 'Editor: delegations', app: :api_entreprise do
  let(:user) { create(:user, editor:) }

  before do
    login_as(user)
  end

  describe 'index' do
    context 'when delegations are enabled' do
      let(:editor) { create(:editor, :delegable) }
      let!(:active_delegation) do
        create(:editor_delegation, editor:,
          authorization_request: create(:authorization_request, :validated, :with_demandeur, api: 'entreprise'))
      end
      let!(:revoked_delegation) do
        create(:editor_delegation, editor:, revoked_at: 1.day.ago,
          authorization_request: create(:authorization_request, :validated, :with_demandeur, api: 'entreprise'))
      end

      it 'displays the delegations tab in header' do
        visit editor_delegations_path

        expect(page).to have_link('Délégations')
      end

      it 'displays delegations with status badges' do
        visit editor_delegations_path

        expect(page).to have_css('.delegation', count: 2)
        expect(page).to have_css('.fr-badge--green-emeraude', text: 'Actif')
        expect(page).to have_css('.fr-badge--pink-tuile', text: 'Révoqué')
      end
    end

    context 'when delegations are not enabled' do
      let(:editor) { create(:editor) }

      it 'does not display the delegations tab in header' do
        visit editor_authorization_requests_path

        expect(page).to have_link('Habilitations')
        expect(page).to have_no_link('Délégations')
      end

      it 'redirects to authorization requests' do
        visit editor_delegations_path

        expect(page).to have_current_path(editor_authorization_requests_path)
      end
    end
  end
end
