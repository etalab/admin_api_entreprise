# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module InstatusClient
  class AddASubscriber
    attr_reader :email, :roles, :page_id, :token

    def initialize(email, *roles)
      @email    = email
      @roles    = roles
      @page_id  = ::Rails.application.credentials.instatus_page_id!
      @token    = ::Rails.application.credentials.instatus_apikey!
    end

    def call
      uri = ::URI.parse("https://api.instatus.com/v1/#{page_id}/subscribers")
      request = ::Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request['Authorization'] = "Bearer #{token}"
      request.body = json_payload

      req_options = {
        use_ssl: uri.scheme == 'https'
      }

      response = ::Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      # @example
      #   response.code # => "200"
      #   response.body # =>
      #   {
      #     "id":"<id>",
      #     "email":"bob@example.email",
      #     "phone":null,
      #     "webhook":null,
      #     "webhookEmail":null,
      #     "discord":null,
      #     "site":{
      #       "id":"<page_id>",
      #       "name":"API Entreprise",
      #       "logoUrl":"https://res.cloudinary.com/sup/image/upload/v1620837982/itq3cx1x8cwzgbjtbw4m.png",
      #       "subdomain":"api-entreprise",
      #       "publicEmail":"",
      #       "language":"fr"
      #     }
      #   }
    end

    private

    def hash_payload
      {
        email:      email,
        components: roles,
        all:        false
      }
    end

    def json_payload
      ::JSON.dump(**hash_payload)
    end
  end
end
