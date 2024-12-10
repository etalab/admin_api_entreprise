RSpec.describe 'Editor: access', app: :api_entreprise do
  subject(:visit_editor) do
    visit editor_path
  end

  context 'without user' do
    it 'redirects to login path' do
      visit_editor

      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'with user' do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end

    it 'redirects to root' do
      visit_editor

      expect(page).to have_current_path(root_path, ignore_query: true)
    end
  end

  context 'with editor' do
    let(:user) { create(:user, :editor) }

    before do
      login_as(user)
    end

    it 'does not redirect to root' do
      visit_editor

      expect(page).to have_current_path(editor_authorization_requests_path, ignore_query: true)
    end
  end
end
