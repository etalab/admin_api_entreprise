RSpec.describe 'follows the prolong token wizard', app: :api_particulier do
  subject(:go_to_prolong_token_start) do
    visit api_particulier_token_prolong_start_path(token_id: token.id)
  end

  let!(:authenticated_user) { create(:user) }
  let!(:non_authenticated_user) { create(:user, :demandeur) }
  let!(:exp) { 88.days.from_now.to_i }
  let!(:api) { 'entreprise' }

  let!(:authorization_request) do
    create(
      :authorization_request,
      :with_demandeur,
      demandeur: authenticated_user,
      api:,
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
    subject(:fill_wizard) do
      go_to_prolong_token_start

      choose(in_charge_option)
      click_button('next_prolong_token_wizard')

      choose(project_purpose_option)
      click_button('next_prolong_token_wizard')

      choose(contact_metier_option) if api == 'entreprise'
      choose(contact_technique_option)
      click_button('next_prolong_token_wizard')
    end

    before do
      login_as(authenticated_user)
    end

    describe 'when contact_technique or contact_metier is not present' do
      let(:in_charge_option) { 'prolong_token_wizard_owner_still_in_charge' }
      let(:project_purpose_option) { 'prolong_token_wizard_project_purpose_true' }

      it 'does not allow to keep contacts' do
        go_to_prolong_token_start

        choose(in_charge_option)
        click_button('next_prolong_token_wizard')

        choose(project_purpose_option)
        click_button('next_prolong_token_wizard')

        expect(page).to have_no_css('#prolong_token_wizard_contact_metier_true')
        expect(page).to have_no_css('#prolong_token_wizard_contact_technique_true')

        expect(page).to have_css('#prolong_token_wizard_contact_metier_false')
        expect(page).to have_css('#prolong_token_wizard_contact_technique_false')
      end
    end

    describe 'when on api entreprise' do
      let!(:authenticated_user) { create(:user, :demandeur, :contact_metier, :contact_technique) }

      let!(:authorization_request) do
        create(
          :authorization_request,
          :with_demandeur,
          :with_contact_metier,
          :with_contact_technique,
          demandeur: authenticated_user,
          contact_metier: authenticated_user,
          contact_technique: authenticated_user,
          api:,
          status: 'validated'
        )
      end

      describe 'fills the wizard' do
        let(:in_charge_option) { 'prolong_token_wizard_owner_still_in_charge' }

        context 'when we valid all questions' do
          let(:project_purpose_option) { 'prolong_token_wizard_project_purpose_true' }
          let(:contact_metier_option) { 'prolong_token_wizard_contact_metier_true' }
          let(:contact_technique_option) { 'prolong_token_wizard_contact_technique_true' }

          it 'prolongs the token' do
            fill_wizard

            click_link('finished_prolong_token_wizard')

            expect(page).to have_content('Votre jeton a été prolongé')
            expect(token.reload.exp).to eq(18.months.from_now.to_i)
          end
        end

        context 'when at least one field has to be changed' do
          let(:project_purpose_option) { 'prolong_token_wizard_project_purpose_false' }
          let(:contact_metier_option) { 'prolong_token_wizard_contact_metier_false' }
          let(:contact_technique_option) { 'prolong_token_wizard_contact_technique_false' }

          it 'follows update path' do
            fill_wizard

            expect(page).to have_content("de la raison d'être du projet")

            expect(token.reload.exp).to eq(exp)
          end
        end
      end
    end

    describe 'when on api particulier' do
      let!(:api) { 'particulier' }
      let!(:authenticated_user) { create(:user, :demandeur, :contact_technique) }

      let!(:authorization_request) do
        create(
          :authorization_request,
          :with_demandeur,
          :with_contact_technique,
          demandeur: authenticated_user,
          contact_technique: authenticated_user,
          api:,
          status: 'validated'
        )
      end

      describe 'fills the wizard' do
        let(:in_charge_option) { 'prolong_token_wizard_owner_still_in_charge' }

        context 'when we valid all questions' do
          let(:project_purpose_option) { 'prolong_token_wizard_project_purpose_true' }
          let(:contact_technique_option) { 'prolong_token_wizard_contact_technique_true' }

          it 'prolongs the token' do
            fill_wizard

            click_link('finished_prolong_token_wizard')

            expect(page).to have_content('Votre jeton a été prolongé')
            expect(page).to have_css('#prolonged_to_authorization_request')

            expect(token.reload.exp).to eq(18.months.from_now.to_i)
          end
        end

        context 'when at least one field has to be changed' do
          let(:project_purpose_option) { 'prolong_token_wizard_project_purpose_false' }
          let(:contact_technique_option) { 'prolong_token_wizard_contact_technique_false' }

          it 'follows update path' do
            fill_wizard

            expect(page).to have_content("de la raison d'être du projet")

            expect(token.reload.exp).to eq(exp)
          end
        end
      end
    end
  end
end
