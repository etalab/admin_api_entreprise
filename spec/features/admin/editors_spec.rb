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

  describe 'update' do
    subject do
      visit edit_admin_editor_path(editor)

      fill_in 'editor_form_uids', with: new_forms

      click_on 'Sauvegarder'
    end

    let(:editor) { create(:editor) }
    let(:new_forms) { 'new_form1, new_form2' }

    it 'works and displays flash message' do
      expect { subject }.to change { editor.reload.form_uids }.to(new_forms.split(', '))

      expect(page).to have_css('.fr-alert.fr-alert--success')
    end
  end
end
