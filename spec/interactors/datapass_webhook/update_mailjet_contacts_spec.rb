# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::UpdateMailjetContacts, type: :interactor do
  subject { described_class.call(authorization_request:) }

  let(:authorization_request) { create(:authorization_request, user:) }
  let(:user) { create(:user, :with_full_name) }

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
  end

  it { is_expected.to be_a_success }

  describe 'without contacts on authorization request' do
    it 'updates mailjet authorization request user with first and last name' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        id: anything,
        action: 'addnoforce',
        contacts: [
          {
            email: user.email,
            properties: {
              'prénom' => user.first_name,
              'nom' => user.last_name,
              'contact_demandeur' => true,
              'contact_métier' => false,
              'contact_technique' => false
            }
          }
        ]
      )

      subject
    end
  end

  context 'with valid contacts' do
    let(:authorization_request) { create(:authorization_request, :with_contacts, user:) }

    it 'updates authorization with all contacts' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        id: anything,
        action: 'addnoforce',
        contacts: [
          {
            email: user.email,
            properties: hash_including(
              'contact_demandeur' => true,
              'contact_métier' => false,
              'contact_technique' => false
            )
          },
          {
            email: authorization_request.contact_metier.email,
            properties: hash_including(
              'contact_demandeur' => false,
              'contact_métier' => true,
              'contact_technique' => false
            )
          },
          {
            email: authorization_request.contact_technique.email,
            properties: hash_including(
              'contact_demandeur' => false,
              'contact_métier' => false,
              'contact_technique' => true
            )
          }
        ]
      )

      subject
    end

    context 'when contact technique is the same as user' do
      before do
        user.update!(
          email: authorization_request.contact_technique.email
        )
      end

      it 'updates accordingly' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          id: anything,
          action: 'addnoforce',
          contacts: [
            {
              email: user.email,
              properties: hash_including(
                'contact_demandeur' => true,
                'contact_métier' => false,
                'contact_technique' => true
              )
            },
            {
              email: authorization_request.contact_metier.email,
              properties: hash_including(
                'contact_demandeur' => false,
                'contact_métier' => true,
                'contact_technique' => false
              )
            }
          ]
        )

        subject
      end
    end

    context 'when contact metier is the same as user' do
      before do
        user.update!(
          email: authorization_request.contact_metier.email
        )
      end

      it 'updates accordingly' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          id: anything,
          action: 'addnoforce',
          contacts: [
            {
              email: user.email,
              properties: hash_including(
                'contact_demandeur' => true,
                'contact_métier' => true,
                'contact_technique' => false
              )
            },
            {
              email: authorization_request.contact_technique.email,
              properties: hash_including(
                'contact_demandeur' => false,
                'contact_métier' => false,
                'contact_technique' => true
              )
            }
          ]
        )

        subject
      end
    end

    context 'when all contacts emails are the same' do
      before do
        authorization_request.contacts.update_all(
          email: user.email
        )
      end

      it 'updates accordingly' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          id: anything,
          action: 'addnoforce',
          contacts: [
            {
              email: user.email,
              properties: hash_including(
                'contact_demandeur' => true,
                'contact_métier' => true,
                'contact_technique' => true
              )
            }
          ]
        )

        subject
      end
    end

    context 'when contact metier and contact technique are the same' do
      let(:another_email) { generate(:email) }

      before do
        authorization_request.contacts.update_all(
          email: another_email
        )
      end

      it 'updates accordingly' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          id: anything,
          action: 'addnoforce',
          contacts: [
            {
              email: user.email,
              properties: hash_including(
                'contact_demandeur' => true,
                'contact_métier' => false,
                'contact_technique' => false
              )
            },
            {
              email: another_email,
              properties: hash_including(
                'contact_demandeur' => false,
                'contact_métier' => true,
                'contact_technique' => true
              )
            }
          ]
        )

        subject
      end
    end
  end
end
