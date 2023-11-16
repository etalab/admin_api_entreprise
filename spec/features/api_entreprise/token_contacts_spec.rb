require 'rails_helper'

RSpec.describe 'token contacts page', app: :api_entreprise do
  subject(:show_token_contact_page) { visit token_contacts_path(token) }

  let(:authorization_request) do
    create(:authorization_request,
      :with_demandeur,
      :with_contact_technique,
      :with_contact_metier,
      demandeur:,
      contact_metier:,
      contact_technique:)
  end
  let(:demandeur) { create(:user, :demandeur) }
  let(:contact_metier) { create(:user, :contact_metier) }
  let(:contact_technique) { create(:user, :contact_technique) }

  after do
    logout
  end

  describe 'connected as a demandeur' do
    before do
      login_as(demandeur)

      show_token_contact_page
    end

    context 'when accessing his own data' do
      let(:token) { create(:token, authorization_request:) }

      it 'displays the metier contact, tech contact, and no button to update the contact data' do
        within('#' << dom_id(contact_metier)) do
          expect(page).to have_css("input[value='#{contact_metier.email}']")
        end

        within('#' << dom_id(contact_technique)) do
          expect(page).to have_css("input[value='#{contact_technique.email}']")
        end

        expect(page).not_to have_button(dom_id(contact_technique, :edit_button))
      end
    end

    context 'when accessing another user data' do
      let(:token) { create(:token) }

      it_behaves_like 'display alert', :error

      it 'redirects to the user profile' do
        expect(page).to have_current_path(user_profile_path)
      end
    end
  end

  describe 'connected as a contact (metier)' do
    before do
      login_as(contact_metier)

      show_token_contact_page
    end

    let(:token) { create(:token, authorization_request:) }

    it 'do not displays the metier contact data' do
      expect(page).not_to have_css("input[value='#{contact_technique.email}']")
    end

    context 'when accessing his own data' do
      it 'does not have a button to update the contact data' do
        expect(page).not_to have_button(dom_id(contact_technique, :edit_button))
      end
    end

    context 'when accessing another user data' do
      let(:token) { create(:token) }

      it_behaves_like 'display alert', :error

      it 'redirects to the user profile' do
        expect(page).to have_current_path(user_profile_path)
      end
    end
  end
end
