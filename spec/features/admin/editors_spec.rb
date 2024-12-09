RSpec.describe 'Admin: editors', app: :api_entreprise do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  describe 'index' do
    let!(:editor) { create(:editor) }
    let!(:editor_user) { create(:user, editor:) }

    before do
      visit admin_editors_path
    end

    it 'displays editors' do
      expect(page).to have_css('.editor', count: 1)

      expect(page).to have_content(editor.name)
      expect(page).to have_content(editor_user.email)
      expect(page).to have_content(editor.form_uids.first)
    end
  end
end
