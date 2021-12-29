require 'rails_helper'

RSpec.describe Mailjet::CreateContacts do
  subject { described_class.call }

  before do
    user.update_attribute(:created_at, creation_period)
  end

  context 'when a user with a tech contact is present in the DB' do
    let(:user) { create(:contact, :tech).authorization_request.user }

    context 'when he was added a long time ago' do
      let(:creation_period) { Faker::Time.between(from: 10.years.ago, to: 1.day.ago) }

      it 'is not posted to Mailjet' do
        expect(Mailjet::Contactslist_managemanycontacts).to_not receive(:create)

        is_expected.to be_a_failure
      end
    end

    context 'when he was recently added' do
      let(:creation_period) { Faker::Time.between(from: 1.day.ago + 1, to: Time.current) }

      it 'is serialized and posted to Mailjet' do
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
  end
end
