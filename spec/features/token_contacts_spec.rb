require 'rails_helper'

RSpec.describe 'token contacts page', type: :feature do
  let(:contact_tech) { create(:contact, :tech) }
  let(:contact_business) { create(:contact, :business) }

  before do
    login_as(user)
    visit token_contacts_path(token)
  end

  shared_examples 'it displays contacts data' do
    it 'displays the business contacts data' do
      within('#' << dom_id(contact_business)) do
        expect(page).to have_css("input[value='#{contact_business.email}']")
        expect(page).to have_css("input[value='#{contact_business.phone_number}']")
      end
    end

    it 'displays the tech contact data' do
      within('#' << dom_id(contact_tech)) do
        expect(page).to have_css("input[value='#{contact_tech.email}']")
        expect(page).to have_css("input[value='#{contact_tech.phone_number}']")
      end
    end
  end

  describe 'connected as a user' do
    let(:user) { create(:user, :with_jwt) }

    context 'when accessing his own data' do
      let(:token) do
        jwt = create(:jwt_api_entreprise, user: user)
        jwt.authorization_request.contacts << [contact_tech, contact_business]
        jwt
      end

      it_behaves_like 'it displays contacts data'

      it 'does not have a button to update the contact data' do
        expect(page).not_to have_button(dom_id(contact_tech, :edit_button))
      end
    end

    context 'when accessing another user data' do
      let(:token) { create(:jwt_api_entreprise) }

      it_behaves_like 'display alert', :error

      it 'redirects to the user profile' do
        expect(page).to have_current_path(user_profile_path)
      end
    end
  end

  describe 'connected as an admin' do
    let(:user) { create(:user, :admin) }
    let(:token) do
      jwt = create(:jwt_api_entreprise)
      jwt.authorization_request.contacts << [contact_tech, contact_business]
      jwt
    end

    it_behaves_like 'it displays contacts data'

    it 'has a button to update the contact data' do
      expect(page).to have_button(dom_id(contact_tech, :edit_button))
    end
  end
end
