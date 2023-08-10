# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::UpdateMailjetContacts, type: :interactor do
  subject { described_class.call(authorization_request:) }

  let(:authorization_request) { create(:authorization_request) }

  before do
    allow(Mailjet::Contactslist_managemanycontacts).to receive(:create)
  end

  it { is_expected.to be_a_success }

  describe 'without contacts on authorization request' do
    let(:authorization_request) { create(:authorization_request, :with_demandeur) }

    it 'updates mailjet authorization request user with first and last name' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        hash_including(
          id: anything,
          action: 'addnoforce',
          contacts: [
            {
              email: authorization_request.demandeur.email,
              properties: {
                'prénom' => authorization_request.demandeur.first_name,
                'nom' => authorization_request.demandeur.last_name,
                'contact_demandeur' => true,
                'contact_métier' => false,
                'contact_technique' => false
              }
            }
          ]
        )
      )

      subject
    end
  end

  context 'with valid contacts' do
    let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_metier, :with_contact_technique) }

    it 'updates authorization with all contacts' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        {
          id: anything,
          action: 'addnoforce',
          contacts: [
            {
              email: authorization_request.demandeur.email,
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
        }
      )

      subject
    end

    context 'when contact technique is the same as user' do
      let(:authorization_request) { create(:authorization_request, :with_contact_metier, :with_roles, roles: %i[demandeur contact_technique]) }

      it 'updates accordingly' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          {
            id: anything,
            action: 'addnoforce',
            contacts: [
              {
                email: authorization_request.demandeur.email,
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
          }
        )

        subject
      end
    end

    context 'when contact metier is the same as user' do
      let(:authorization_request) { create(:authorization_request, :with_contact_technique, :with_roles, roles: %i[demandeur contact_metier]) }

      it 'updates accordingly' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          hash_including(
            id: anything,
            action: 'addnoforce',
            contacts: [
              {
                email: authorization_request.demandeur.email,
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
        )

        subject
      end
    end

    context 'when all contacts emails are the same' do
      let(:authorization_request) { create(:authorization_request, :with_roles, roles: %i[demandeur contact_metier contact_technique]) }

      it 'updates accordingly' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          hash_including(
            id: anything,
            action: 'addnoforce',
            contacts: [
              {
                email: authorization_request.users.first.email,
                properties: hash_including(
                  'contact_demandeur' => true,
                  'contact_métier' => true,
                  'contact_technique' => true
                )
              }
            ]
          )
        )

        subject
      end
    end

    context 'when contact metier and contact technique are the same' do
      let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_roles, roles: %i[contact_metier contact_technique]) }

      it 'updates accordingly' do
        expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
          hash_including(
            id: anything,
            action: 'addnoforce',
            contacts: [
              {
                email: authorization_request.demandeur.email,
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
                  'contact_technique' => true
                )
              }
            ]
          )
        )

        subject
      end
    end
  end

  describe 'when on API Particulier' do
    let(:authorization_request) { create(:authorization_request, :with_demandeur, :with_contact_technique, api: 'particulier') }

    it 'updates accordingly' do
      expect(Mailjet::Contactslist_managemanycontacts).to receive(:create).with(
        {
          id: anything,
          action: 'addnoforce',
          contacts: [
            {
              email: authorization_request.demandeur.email,
              properties: {
                'contact_demandeur' => true,
                'contact_technique' => false,
                'nom' => 'Gigot',
                'prénom' => 'Jean-Marie'
              }
            },
            {
              email: authorization_request.contact_technique.email,
              properties: {
                'contact_demandeur' => false,
                'contact_technique' => true,
                'nom' => 'Gigot',
                'prénom' => 'Jean-Marie'
              }
            }
          ]
        }
      )

      subject
    end
  end
end
