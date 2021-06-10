# frozen_string_literal: true

module InstatusContacts::Operation
  class Create < ::Trailblazer::Operation
    step :find_contact
    step :add_subscriber

    def find_contact(ctx, params:, **)
      ctx[:contact] = ::Contact.find_by(id: params.fetch('id'))
      !ctx[:contact].nil?
    end

    def add_subscriber(ctx, contact:, **)
      email, roles = build_contact_attributes(contact)
      components = roles.map { |role| ::Rails.application.config_for(:instatus).dig(:components, role.to_sym) }

      return true if Rails.env.development?

      result = ::InstatusClient::AddASubscriber.new(email, *components).call
      result.code == '200' && ::JSON.parse(result.body).dig(0, 'email') == email
    end

    private

    def build_contact_attributes(contact)
      [
        contact.email,
        contact.jwt_api_entreprise.access_roles
      ]
    end
  end
end
