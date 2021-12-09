require 'rails_helper'

RSpec.describe 'edit contacts', type: :feature do
  let(:admin) { create(:user, :admin) }
  let(:contact) { create(:contact) }
  let(:token) do
    jwt = create(:jwt_api_entreprise)
    jwt.authorization_request.contacts << contact
    jwt
  end

  before do
    login_as(admin)
    visit token_contacts_path(token)
    click_button(dom_id(contact, :edit_button))
  end

  describe '#email' do
    subject(:edit!) do
      fill_in :contact_email, with: email
      click_button
    end

    context 'when the email is valid' do
      let(:email) { 'valid@email.com' }

      it 'updates the contact email' do
        edit!

        expect(contact.reload.email).to eq(email)
      end

      it 'redirects to the token contacts list' do
        edit!

        expect(page).to have_current_path(token_contacts_path(token))
      end

      it_behaves_like :display_alert, :success
    end

    context 'when the email is blank' do
      let(:email) { '' }

      it_behaves_like :display_alert, :error

      it 'does not change the email' do
        expect { edit! }.not_to change(contact, :email)
      end
    end

    context 'when the email format is invalid' do
      let(:email) { 'not an email' }

      it_behaves_like :display_alert, :error

      it 'does not change the email' do
        expect { edit! }.not_to change(contact, :email)
      end
    end
  end

  describe '#phone_number' do
    subject(:edit!) do
      fill_in :contact_phone_number, with: phone_number
      click_button
    end

    context 'when it is present' do
      let(:phone_number) { '1234' }

      it 'updates the contact phone number' do
        edit!

        expect(contact.reload.phone_number).to eq(phone_number)
      end

      it 'redirects to the token contacts list' do
        edit!

        expect(page).to have_current_path(token_contacts_path(token))
      end

      it_behaves_like :display_alert, :success
    end

    context 'when it is absent' do
      let(:phone_number) { '' }

      it 'updates the contact phone number' do
        edit!

        expect(contact.reload.phone_number).to eq(phone_number)
      end

      it 'redirects to the token contacts list' do
        edit!

        expect(page).to have_current_path(token_contacts_path(token))
      end

      it_behaves_like :display_alert, :success
    end
  end
end
