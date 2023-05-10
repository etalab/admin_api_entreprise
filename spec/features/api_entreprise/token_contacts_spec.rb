require 'rails_helper'

RSpec.describe 'token contacts page', app: :api_entreprise do
  let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_metier, :with_contact_technique) }
  let(:user) { authorization_request.demandeur }
  let(:contact_metier) { authorization_request.contact_metier }
  let(:contact_technique) { authorization_request.contact_technique }

  before do
    login_as(user)
    visit token_contacts_path(token)
  end

  shared_examples 'it displays contacts data' do
    it 'displays the metier contact data' do
      within('#' << dom_id(contact_metier)) do
        expect(page).to have_css("input[value='#{contact_metier.email}']")
        expect(page).to have_css("input[value='#{contact_metier.phone_number}']")
      end
    end

    it 'displays the tech contact data' do
      within('#' << dom_id(contact_technique)) do
        expect(page).to have_css("input[value='#{contact_technique.email}']")
        expect(page).to have_css("input[value='#{contact_technique.phone_number}']")
      end
    end
  end

  describe 'connected as a demandeur' do
    let(:user) { authorization_request.demandeur }

    context 'when accessing his own data' do
      let(:authorization_request) { create(:authorization_request, :with_contact_metier, :with_contact_technique, :with_roles, roles: %i[demandeur contact_technique]) }
      let(:token) { create(:token, authorization_request:) }

      it_behaves_like 'it displays contacts data'

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

  describe 'connected as a contact (metier)' do
    let(:user) { contact_metier }
    let(:authorization_request) { create(:authorization_request, :with_contact_metier, :with_contact_technique, :with_roles, roles: %i[demandeur contact_technique]) }
    let(:token) { create(:token, authorization_request:) }

    it 'do not displays the metier contact data' do
      expect(page).not_to have_css("input[value='#{contact_technique.email}']")
      expect(page).not_to have_css("input[value='#{contact_technique.phone_number}']")
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
