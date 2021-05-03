# frozen_string_literal: true

module MailjetContact::Operation
  class Create < ::Trailblazer::Operation
    step :fetch_users
    step :build_payload
    step :create_to_mailjet

    def fetch_users(ctx, **)
      ctx[:users_relation] = ::User.added_since_yesterday.includes(:contacts)
      ctx[:users_relation].exists?
    end

    def build_payload(ctx, users_relation:, **)
      serialized_contacts = []

      users_relation.find_each do |user|
        serialized_properties = {
          'contact_demandeur': nil,   # Bool
          'contact_écosystème': nil,  # Bool
          'contact_éditeur': nil,     # Bool
          'contact_métier': nil,      # Bool
          'contact_technique': nil,   # Bool
          'default': nil,             # String
          'incidents': nil,           # Bool
          'infolettre': nil,          # Bool
          'nom': nil,                 # String
          'origine': nil,             # String
          'prénom': nil,              # String
          'techlettre': nil           # Bool
        }

        serialized_properties[:'contact_demandeur'] = user.contacts.map(&:contact_type).include?('other')
        serialized_properties[:'contact_technique'] = user.contacts.map(&:contact_type).include?('tech')
        serialized_properties[:'contact_métier']    = user.contacts.map(&:contact_type).include?('admin')
        serialized_properties[:'infolettre']        = true
        serialized_properties[:'techlettre']        = user.contacts.map(&:contact_type).include?('tech')

        serialized_contact = {
          email: user.email,
          properties: serialized_properties.compact
        }

        serialized_contacts << serialized_contact
      end

      ctx[:serialized_contacts] = serialized_contacts
      ctx[:serialized_contacts].any?
    end

    def create_to_mailjet(ctx, serialized_contacts:, **)
      require 'net/http'
      require 'uri'
      require 'json'

      uri = URI.parse("https://api.mailjet.com/v3/REST/contactslist/#{ENV.fetch('MJ_LIST_ID')}/managemanycontacts")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(ENV.fetch('MJ_APIKEY_PUBLIC'), ENV.fetch('MJ_APIKEY_PRIVATE'))
      request.content_type = "application/json"
      request.body = JSON.dump({
        "Action" => "addnoforce",
        "Contacts" => serialized_contacts
      })

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      %w[200 201].include?(response.code)
    end
  end
end
