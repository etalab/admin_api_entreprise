RSpec.describe 'Editor: authorization requests', app: :api_entreprise do
  let(:user) { create(:user, editor:) }
  let(:editor) { create(:editor, copy_token:, form_uids: %w[form1 form2]) }
  let(:copy_token) { false }

  before do
    login_as(user)
  end

  describe 'index' do
    let!(:valid_authorization_requests) do
      [
        create(:authorization_request, :validated, :with_multiple_tokens_one_valid, api: 'entreprise', demarche: 'form1'),
        create(:authorization_request, :validated, api: 'entreprise', demarche: 'form2')
      ]
    end

    let!(:invalid_authorization_requests) do
      [
        create(:authorization_request, :validated, api: 'entreprise', demarche: 'wrong_form'),
        create(:authorization_request, :validated, api: 'particulier', demarche: 'form1'),
        create(:authorization_request, api: 'entreprise', demarche: 'form1')
      ]
    end

    it 'displays authorization requests linked to editor with token status' do
      visit editor_authorization_requests_path

      expect(page).to have_css('.authorization-request', count: 2)

      expect(page).to have_css('#' << dom_id(valid_authorization_requests[0]))
      expect(page).to have_css('#' << dom_id(valid_authorization_requests[1]))

      expect(page).to have_content('Nouveau jeton à utiliser')
    end

    describe 'copy token behaviour' do
      context 'when editor has no copy token' do
        let(:copy_token) { false }

        it 'does not have copy token button' do
          visit editor_authorization_requests_path

          expect(page).to have_no_css('.copy-token')
          expect(page.html).not_to include(valid_authorization_requests.first.token.rehash)
        end
      end

      context 'when editor can copy token' do
        let(:copy_token) { true }

        it 'has a button to copy token' do
          visit editor_authorization_requests_path

          expect(page).to have_css('.copy-token', count: 2)
          expect(page.html).to include(valid_authorization_requests.first.token.rehash)
        end
      end
    end
  end

  describe 'search' do
    subject(:search) do
      visit editor_authorization_requests_path

      fill_in 'search_main_input', with: valid_authorization_request.demandeur.email

      click_on 'Rechercher'
    end

    let!(:valid_authorization_request) { create(:authorization_request, :validated, :with_demandeur, api: 'entreprise', demarche: 'form1') }
    let!(:invalid_authorization_request) { create(:authorization_request, :validated, :with_demandeur, api: 'entreprise', demarche: 'form1') }

    it 'displays the valid authorization request' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_content(valid_authorization_request.demandeur.email)
    end
  end
end
