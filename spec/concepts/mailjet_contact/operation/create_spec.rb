require 'rails_helper'

RSpec.describe MailjetContacts::Operation::Create do
  subject { described_class.call }

  before do
    user.update_attribute(:created_at, creation_period)
  end

  let(:user) { create(:contact, type).jwt_api_entreprise.user }

  context 'when users were added a long time ago' do
    let(:creation_period) { Faker::Time.between(from: 10.years.ago, to: 1.day.ago) }

    context 'when the contact is tech' do
      let(:type) { :tech }

      it 'do not send any contacts to Mailjet' do
        expect(Mailjet::Contactslist_managemanycontacts).to_not receive(:create)

        is_expected.to be_a_failure
      end
    end

    context 'when the contact is business' do
      let(:type) { :business }

      it 'do not send any contacts to Mailjet' do
        expect(Mailjet::Contactslist_managemanycontacts).to_not receive(:create)

        is_expected.to be_a_failure
      end
    end

    context 'when the contact is other' do
      let(:type) { :other }

      it 'do not send any contacts to Mailjet' do
        expect(Mailjet::Contactslist_managemanycontacts).to_not receive(:create)

        is_expected.to be_a_failure
      end
    end
  end

  context 'when users were recently added' do
    let(:creation_period) { Faker::Time.between(from: 1.day.ago + 1, to: Time.current) }

    context 'when the contact is tech' do
      let(:type) { :tech }

      it 'does send the contact to Mailjet' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          action: 'addnoforce',
          contacts: [
            {
              'email': user.email,
              'properties': {
                'contact_demandeur':  false,
                'contact_métier':     false,
                'contact_technique':  true,
                'infolettre':         true,
                'origine':            'dashboard',
                'techlettre':         true
              }
            }
          ],
          id: Rails.application.credentials.mj_list_id!
        )

        is_expected.to be_a_success
      end
    end

    context 'when the contact is business' do
      let(:type) { :business }

      it 'does send the contact to Mailjet' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          action: 'addnoforce',
          contacts: [
            {
              'email': user.email,
              'properties': {
                'contact_demandeur':  false,
                'contact_métier':     true,
                'contact_technique':  false,
                'infolettre':         true,
                'origine':            'dashboard',
                'techlettre':         false
              }
            }
          ],
          id: Rails.application.credentials.mj_list_id!
        )

        is_expected.to be_a_success
      end
    end

    context 'when the contact is other' do
      let(:type) { :other }

      it 'does send the contact to Mailjet' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          action: 'addnoforce',
          contacts: [
            {
              'email': user.email,
              'properties': {
                'contact_demandeur':  true,
                'contact_métier':     false,
                'contact_technique':  false,
                'infolettre':         true,
                'origine':            'dashboard',
                'techlettre':         false
              }
            }
          ],
          id: Rails.application.credentials.mj_list_id!
        )

        is_expected.to be_a_success
      end
    end
  end
end
