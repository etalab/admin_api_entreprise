# frozen_string_literal: true

module MailjetContacts::Operation
  class Create < ::Trailblazer::Operation
    step :fetch_users
    step :build_payload
    step :create_to_mailjet

    def fetch_users(ctx, **)
      ctx[:users_relation] = ::User.added_since_yesterday.includes(:contacts)
      ctx[:users_relation].exists?
    end

    def build_payload(ctx, users_relation:, **)
      ctx[:serialized_contacts] = users_relation.find_each.with_object([]) do |user, serialized_contacts|
        serialized_properties = {
          contact_demandeur:  user.contacts.map(&:contact_type).include?('other'),
          contact_écosystème: nil,
          contact_éditeur:    nil,
          contact_métier:     user.contacts.map(&:contact_type).include?('admin'),
          contact_technique:  user.contacts.map(&:contact_type).include?('tech'),
          default:            nil,
          incidents:          nil,
          infolettre:         true,
          nom:                nil,
          origine:            'dashboard',
          prénom:             nil,
          techlettre:         user.contacts.map(&:contact_type).include?('tech')
        }

        serialized_contact = {
          email: user.email,
          properties: serialized_properties.compact
        }

        serialized_contacts << serialized_contact
      end

      ctx[:serialized_contacts].any?
    end

    def create_to_mailjet(ctx, serialized_contacts:, **)
      Mailjet::Contactslist_managemanycontacts.create(
        id:       ::Rails.application.credentials.mj_list_id!,
        action:   'addnoforce',
        contacts: serialized_contacts
      )

      true
    end
  end
end
