# frozen_string_literal: true

module MailjetContacts::Operation
  class Create < ::Trailblazer::Operation
    step :fetch_users_and_build_payload
    step :create_to_mailjet

    def fetch_users_and_build_payload(ctx, **)
      ctx[:payload] = ::User.added_since_yesterday.includes(:contacts).find_each.map do |user|
        {
          email:      user.email,
          properties: ::Mailjet::PropertyBuilder.new(user).call
        }
      end

      ctx[:payload].any?
    end

    def create_to_mailjet(ctx, payload:, **)
      Mailjet::Contactslist_managemanycontacts.create(
        id:       ::Rails.application.credentials.mj_list_id!,
        action:   'addnoforce',
        contacts: payload
      )

      true
    end
  end
end
