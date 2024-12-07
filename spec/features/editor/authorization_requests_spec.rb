RSpec.describe 'Editor: authorization requests', app: :api_entreprise do
  let(:user) { create(:user, editor:) }
  let(:editor) { create(:editor, form_uids: %w[form1 form2]) }

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
  end
end
