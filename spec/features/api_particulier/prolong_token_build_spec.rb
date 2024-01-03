RSpec.describe 'follows the prolong token wizard', app: :api_particulier do
  subject(:go_to_prolong_token_start) do
    visit api_particulier_token_prolong_start_path(token_id: token.id)
  end

  let!(:authenticated_user) { create(:user) }
  let!(:non_authenticated_user) { create(:user, :demandeur) }
  let!(:exp) { 88.days.from_now.to_i }

  let!(:authorization_request) do
    create(
      :authorization_request,
      :with_demandeur,
      demandeur: authenticated_user,
      api: 'entreprise',
      status: 'validated'
    )
  end

  let!(:token) do
    create(:token, authorization_request:, exp:)
  end

  describe 'when user is not authenticated' do
    it 'redirects to the login' do
      go_to_prolong_token_start
      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end
  end

  describe 'when user is authenticated' do
    before do
      login_as(authenticated_user)
    end

    describe 'when following the wizard' do
      it 'is on happy path and is prolonged' do
        go_to_prolong_token_start

        choose('prolong_token_wizard_owner_still_in_charge')
        click_button('next_prolong_token_wizard')
        expect(current_url).to include('project_purpose')

        choose('prolong_token_wizard_project_purpose_true')
        click_button('next_prolong_token_wizard')
        expect(current_url).to include('contacts')

        choose('prolong_token_wizard_contact_metier_true')
        choose('prolong_token_wizard_contact_technique_true')
        click_button('next_prolong_token_wizard')
        expect(current_url).to include('summary')

        click_link('finished_prolong_token_wizard')
        expect(current_url).to include('finished')

        expect(page).to have_content('Votre jeton a été prolongé')
        expect(page).to have_css('#prolonged_to_authorization_request')

        expect(token.reload.exp).to eq(18.months.from_now.to_i)
      end

      it 'is on happy path and it requires update' do
        go_to_prolong_token_start

        choose('prolong_token_wizard_owner_still_in_charge')
        click_button('next_prolong_token_wizard')
        expect(current_url).to include('project_purpose')

        choose('prolong_token_wizard_project_purpose_false')
        click_button('next_prolong_token_wizard')
        expect(current_url).to include('contacts')

        choose('prolong_token_wizard_contact_metier_true')
        choose('prolong_token_wizard_contact_technique_true')
        click_button('next_prolong_token_wizard')
        expect(current_url).to include('summary')

        expect(page).to have_content("de la raison d'être du projet")

        expect(token.reload.exp).to eq(exp)
      end
    end
  end
end
