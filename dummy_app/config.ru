require 'bundler/setup'
require 'sinatra/base'
require 'omniauth-oauth2'
require 'net/http'
require 'json'

OmniAuth.configure do |config|
  config.allowed_request_methods = %i[get post]
  config.full_host = ENV.fetch('DS_FULL_HOST', 'http://ds.api.localtest.me:5678')
  config.on_failure = proc do |env|
    message = env['omniauth.error.type'] || 'unknown_error'
    Rack::Response.new([''], 302, 'Location' => "/auth/failure?message=#{message}").finish
  end
end

# Simple OAuth2 strategy wired to the API Entreprise Doorkeeper server.
module OmniAuth
  module Strategies
    # Name aligns with OmniAuth camelization of :api_entreprise -> ApiEntreprise.
    class ApiEntreprise < OmniAuth::Strategies::OAuth2
      option :name, :api_entreprise

      option :client_options, {
        site: ENV.fetch('API_ENTREPRISE_OAUTH_SITE', 'http://entreprise.api.localtest.me:3000'),
        authorize_url: '/oauth/authorize',
        token_url: '/oauth/token'
      }

      uid { raw_info['sub'] || raw_info['uid'] }
      info { raw_info }

      def raw_info
        @raw_info ||= access_token.to_hash
      end
    end
  end
end

class DummyDsApp < Sinatra::Base
  configure do
    enable :sessions
    default_secret = '0123456789abcdef' * 4 # 64 chars
    set :session_secret, ENV.fetch('SESSION_SECRET', default_secret)
    set :protection, false
    set :host_authorization, permitted_hosts: ['.localtest.me', 'localhost']

    use OmniAuth::Builder do
      provider(
        :api_entreprise,
        ENV.fetch('DS_OAUTH_CLIENT_ID', 'dummy-ds-client-id'),
        ENV.fetch('DS_OAUTH_CLIENT_SECRET', 'dummy-ds-client-secret')
      )
    end
  end

  # rubocop:disable Metrics/BlockLength
  helpers do
    def api_tokens
      @api_tokens ||= fetch_api_tokens(session[:access_token])
    end

    def connected?
      token = session[:access_token]
      token && !token.empty?
    end

    def oauth_site
      ENV.fetch('API_ENTREPRISE_OAUTH_SITE', 'http://entreprise.api.localtest.me:3000')
    end

    def fetch_oauth_data(access_token)
      return {} unless access_token

      uri = URI("#{oauth_site}/oauth/me")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{access_token}"

      response = http.request(request)
      return {} unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue StandardError
      {}
    end

    def oauth_data
      @oauth_data ||= fetch_oauth_data(session[:access_token])
    end

    def oauth_token_info
      oauth_data['oauth_token'] || {}
    end

    def api_tokens
      oauth_data['api_tokens'] || []
    end

    def revoke_oauth_token
      return unless session[:access_token]

      uri = URI("#{oauth_site}/oauth/revoke")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(
        'token' => session[:access_token],
        'client_id' => ENV.fetch('DS_OAUTH_CLIENT_ID', 'dummy-ds-client-id'),
        'client_secret' => ENV.fetch('DS_OAUTH_CLIENT_SECRET', 'dummy-ds-client-secret')
      )
      http.request(request)
    rescue StandardError
      nil
    end
  end
  # rubocop:enable Metrics/BlockLength

  get '/' do
    redirect '/settings'
  end

  get '/settings' do
    erb :settings
  end

  get '/logout' do
    revoke_oauth_token
    session.clear
    redirect '/settings'
  end

  get '/reconnect' do
    revoke_oauth_token
    session.clear
    redirect '/auth/api_entreprise'
  end

  get '/auth/:provider/callback' do
    auth = request.env['omniauth.auth']
    creds = auth['credentials'] || {}

    session[:access_token] = creds['token']
    session[:refresh_token] = creds['refresh_token']
    session[:expires_at] = creds['expires_at']
    session[:token_type] = creds['token_type']
    session[:scope] = auth.dig('info', 'scope')
    session[:created_at] = creds['created_at'] || Time.now.to_i

    redirect '/settings'
  end

  get '/auth/failure' do
    @message = params[:message]
    erb :failure
  end
end

run DummyDsApp
