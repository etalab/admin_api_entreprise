require 'rails_helper'

RSpec.describe MailjetContacts::Operation::Create do
  subject { described_class.call }

  before do
    create(:contact, :tech, jwt_api_entreprise: jwt_api_entreprise)
    create(:contact, :business, jwt_api_entreprise: jwt_api_entreprise)
    create(:contact, :other, jwt_api_entreprise: jwt_api_entreprise)
  end

  let(:user) do
    create(:user, created_at: created_date)
  end

  let(:jwt_api_entreprise) { create(:jwt_api_entreprise, user: user) }

  context 'when users were added a long time ago' do
    let(:created_date) { 2.years.ago }

    it 'do not send any contacts to Mailjet' do
      expect(Mailjet::Contactslist_managemanycontacts).to_not receive(:create)

      is_expected.to be_a_failure
    end
  end

  context 'when users were recently added' do
    let(:created_date) { 2.minutes.ago }

    it 'does send the contact to Mailjet' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        action: 'addnoforce',
        contacts: [
          {
            'email': user.email,
            'properties': {
              'contact_demandeur':  true,
              'contact_métier':     true,
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
end
