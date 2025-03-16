RSpec.describe 'Admin: users', app: :api_entreprise do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  describe 'impersonification' do
    subject(:impersonate) do
      visit admin_users_path

      click_on dom_id(user, :impersonate)
    end

    let!(:user) { create(:user) }

    it 'redirects to user\'s account as the user, with a warning' do
      impersonate

      expect(page).to have_content("connecté en tant que #{user.email}")
      expect(page).to have_current_path(authorization_requests_path)
    end
  end

  describe 'search' do
    subject(:search) do
      visit admin_users_path

      fill_in 'search_main_input', with: valid_user.email

      click_on 'Rechercher'
    end

    let!(:valid_user) { create(:user) }
    let!(:invalid_user) { create(:user) }

    it 'displays the valid user' do
      search

      expect(page).to have_css('.user', count: 1)
      expect(page).to have_content(valid_user.email)
      expect(page).to have_no_content(invalid_user.email)
    end
  end

  describe 'adding an editor to a specific user' do
    subject(:add_editor) do
      visit admin_users_path

      click_on dom_id(user, :edit)

      select editor.name, from: 'user_editor_id'

      click_on 'submit'
    end

    let!(:user) { create(:user, editor: nil) }
    let!(:editor) { create(:editor) }

    it 'adds the editor to the user' do
      add_editor

      expect(user.reload.editor).to eq(editor)
      expect(page).to have_css('.fr-alert.fr-alert--success')
    end
  end

  describe 'provider behavior' do
    let!(:user_with_providers) { create(:user, provider_uids: %w[insee dgfip]) }
    let!(:user_without_providers) { create(:user, provider_uids: %w[]) }

    describe 'display in users list' do
      it 'displays associated providers for each user' do
        visit admin_users_path

        within("##{dom_id(user_with_providers)}") do
          within('.user-providers') do
            expect(page).to have_content('INSEE')
            expect(page).to have_content('DGFIP')
          end
        end

        within("##{dom_id(user_without_providers)}") do
          within('.user-providers') do
            expect(page).to have_no_content('INSEE')
            expect(page).to have_no_content('DGFIP')
          end
        end
      end
    end

    describe 'updating user provider associations' do
      subject(:add_provider_to_user) do
        visit admin_users_path

        click_on dom_id(user, :edit)

        check 'user_provider_uid_dgfip'

        click_on 'submit'
      end

      let!(:user) { create(:user, provider_uids: ['insee']) }

      it 'allows adding providers to a user' do
        add_provider_to_user

        expect(page).to have_css('.fr-alert.fr-alert--success')
        expect(user.reload.provider_uids).to contain_exactly('insee', 'dgfip')

        within("##{dom_id(user)}") do
          within('.user-providers') do
            expect(page).to have_content('INSEE')
            expect(page).to have_content('DGFIP')
          end
        end
      end
    end
  end
end
